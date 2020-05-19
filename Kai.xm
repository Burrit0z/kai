#include <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#include <stdio.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "KAIBattery.mm"

@interface UIApplication (Kai)
+(id)sharedApplication;
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface CSAdjunctListView : UIView
@property (nonatomic, assign) BOOL hasKai;
@property (nonatomic, assign) NSInteger previousKaiCount;
-(UIStackView *)stackView;
-(void)setStackView:(UIStackView *)arg1;
-(void)KaiUpdate;
@end

@interface CSMainPageView : UIView
-(void)updateForPresentation:(id)arg1;
@end

@interface _CSSingleBatteryChargingView : UIView
@end

@interface NCNotificationListView : UIView
@end

BOOL setFrame = NO;
CGRect original = CGRectMake(0,0,0,0);
CGRect originalBattery;


%hook CSAdjunctListView
%property (nonatomic, assign) BOOL hasKai;
%property (nonatomic, assign) NSInteger previousKaiCount;

-(void)_layoutStackView {

	//NSLog(@"Kai: Laying out stack view");

	[self KaiUpdate];

	%orig;
}

-(void)setStackView:(UIStackView *)arg1 {
	//NSLog(@"Kai: Updating setting stack view");

	if(!self.hasKai) {
		KAIBattery *battery = [[KAIBattery alloc] initWithFrame:CGRectMake(8, 0, UIScreen.mainScreen.bounds.size.width, 85)];
		battery.translatesAutoresizingMaskIntoConstraints = NO;
        [battery.leftAnchor constraintEqualToAnchor:battery.leftAnchor constant:0].active = YES;
        [battery.topAnchor constraintEqualToAnchor:battery.topAnchor constant:0].active = YES;
        [battery.widthAnchor constraintEqualToConstant:[self stackView].frame.size.width - 16].active = YES;
		originalBattery = battery.frame;
		original = [self stackView].frame;
		setFrame = YES;
		self.previousKaiCount = 0;
		self.hasKai = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(KaiInfo)
			name:@"KaiInfoChanged"
			object:nil];
	//[self addSubview:[KAIBattery sharedInstance]];
	[[KAIBattery sharedInstance] darkLightMode];
	}

	UIStackView *newView = arg1;

	if(![arg1.subviews containsObject:[KAIBattery sharedInstance]]) {
		[newView addArrangedSubview:[KAIBattery sharedInstance]];
		UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,359,80)];
		[view setBackgroundColor:[UIColor redColor]];
		//[view setIntrinsicContentSize:CGSizeMake(359,80)];
		[newView addArrangedSubview:view];
	}
	%orig(newView);
	//%orig(arg1);
}

%new
-(void)KaiUpdate {
	[[KAIBattery sharedInstance] darkLightMode];
	KAIBattery *battery = [KAIBattery sharedInstance];
	//battery.translatesAutoresizingMaskIntoConstraints = YES;
	battery.frame = CGRectMake(
		originalBattery.origin.x,
		originalBattery.origin.y,
		originalBattery.size.width,
		(battery.number * 85)
	);

	battery.translatesAutoresizingMaskIntoConstraints = NO;
        [battery.leftAnchor constraintEqualToAnchor:battery.leftAnchor constant:0].active = YES;
        [battery.topAnchor constraintEqualToAnchor:battery.topAnchor constant:0].active = YES;
        [battery.widthAnchor constraintEqualToConstant:[self stackView].frame.size.width - 16].active = YES;
		[battery.heightAnchor constraintEqualToConstant:(battery.number * 85)].active = YES;
}

%new
-(void)KaiInfo {
	NSLog(@"Kai: Updating Info");
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

	//[self setValue:@"crash" forKeyPath:@"euhidehuud"];

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
