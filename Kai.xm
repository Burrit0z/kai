#include <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#include <stdio.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "KAIBattery.mm"
#define KAISelf ((CSAdjunctListView *)self)

@interface UIApplication (Kai)
+(id)sharedApplication;
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface CSAdjunctListView : UIView
@property (nonatomic, assign) BOOL hasKai;
-(UIStackView *)stackView;
-(void)setStackView:(UIStackView *)arg1;
-(void)KaiUpdate;
@end

@interface SBDashBoardAdjunctListView : UIView
@property (nonatomic, assign) BOOL hasKai;
-(UIStackView *)stackView;
-(void)setStackView:(UIStackView *)arg1;
-(void)KaiUpdate;
@end

@interface CSMainPageView : UIView
-(void)updateForPresentation:(id)arg1;
@end

@interface _CSSingleBatteryChargingView : UIView
@end

@interface NSLayoutConstraint (Kai)
+(id)constraintWithAnchor:(id)arg1 relatedBy:(long long)arg2 toAnchor:(id)arg3 multiplier:(double)arg4 constant:(double)arg5 ;
@end


%hook KAITarget
%property (nonatomic, assign) BOOL hasKai;

-(void)_layoutStackView {

	//NSLog(@"Kai: Laying out stack view");

	[self KaiUpdate];

	%orig;
}

-(void)setStackView:(UIStackView *)arg1 {

	if(!KAISelf.hasKai) {
		KAIBattery *battery = [[KAIBattery alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(KaiInfo)
			name:@"KaiInfoChanged"
			object:nil];
		KAISelf.hasKai = YES;
	[[KAIBattery sharedInstance] darkLightMode];

	UIStackView *newView = arg1;

	if(![arg1.subviews containsObject:battery]) {
		[newView addArrangedSubview:battery];
	}

	%orig(newView);

	}
}

%new
-(void)KaiUpdate {
	[[KAIBattery sharedInstance] darkLightMode];
	KAIBattery *battery = [KAIBattery sharedInstance];

	[UIView animateWithDuration:0.3 animations:^{

		if(!battery.heightConstraint) {
			
			battery.heightConstraint.active = NO;
			NSLog(@"kai: 1st time, assigning to %d", 500);
			battery.heightConstraint = [battery.heightAnchor constraintEqualToConstant:500];
			battery.heightConstraint.active = YES;

		} else {
		int height = (battery.number * 85);
			battery.heightConstraint.active = NO;
			NSLog(@"kai: setting to %d", height);
			battery.heightConstraint.constant = height;
			battery.heightConstraint.active = YES;

			UIStackView *s = [self stackView];
			s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, (s.frame.size.height - 1));
		}

	}];
	
}

%new
-(void)KaiInfo {
	[[KAIBattery sharedInstance] updateBattery];
	[self KaiUpdate];
}
%end


%hook BCBatteryDevice

- (id)initWithIdentifier:(id)arg1 vendor:(long long)arg2 productIdentifier:(long long)arg3 parts:(unsigned long long)arg4 matchIdentifier:(id)arg5 {

	[self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"charging" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"powerSourceState" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"batterySaverModeActive" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"percentCharge" options:NSKeyValueObservingOptionNew context:nil];

	return %orig;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	dispatch_async(dispatch_get_main_queue(), ^{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KaiInfoChanged" object:nil userInfo:nil];
	});
	
}
%end

%hook _CSSingleBatteryChargingView

-(void)initWithFrame:(CGRect)arg1 {
	%orig;
	[self removeFromSuperview];
}

-(CGFloat)desiredVisibilityDuration {
	return 0;
}

-(void)setBatteryVisible:(BOOL)arg1 {
	%orig(NO);
}

%end

%ctor {
	Class cls = kCFCoreFoundationVersionNumber > 1600 ? ([objc_getClass("CSAdjunctListView") class]) : ([objc_getClass("SBDashBoardAdjunctListView") class]);
    %init(KAITarget = cls);
}
