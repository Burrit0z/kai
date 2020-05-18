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
@property (nonatomic, strong) KAIBattery *batteryView;
@property (nonatomic, assign) BOOL hasKai;
@property (nonatomic, assign) NSInteger previousKaiCount;
-(UIView *)stackView;
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
%property (nonatomic, strong) KAIBattery *batteryView;
%property (nonatomic, assign) BOOL hasKai;
%property (nonatomic, assign) NSInteger previousKaiCount;

-(void)_layoutStackView {
	NSLog(@"Kai: Laying out stack view");
	//%orig;

	if(!self.hasKai) {
	//original = self.superview.superview.frame;
		self.batteryView = [[KAIBattery alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.origin.x, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
		originalBattery = self.batteryView.frame;
		//[[self stackView] addSubview:self.batteryView];
		setFrame = YES;
		self.previousKaiCount = 0;
		self.hasKai = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(KaiInfo)
			name:@"KaiInfoChanged"
			object:nil];
	[self.batteryView darkLightMode];
	//[self setStackView:self.batteryView];
	}

	[self KaiUpdate];

	%orig;
}

-(void)setStackView:(UIStackView *)arg1 {
	NSLog(@"Kai: Updating setting stack view");

	if(!self.hasKai) {
	//original = self.superview.superview.frame;
		self.batteryView = [[KAIBattery alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
		originalBattery = self.batteryView.frame;
		//[[self stackView] addSubview:self.batteryView];
		setFrame = YES;
		self.previousKaiCount = 0;
		self.hasKai = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(KaiInfo)
			name:@"KaiInfoChanged"
			object:nil];
	[self.batteryView darkLightMode];
	//[self setStackView:self.batteryView];
	}

	UIStackView *newView = arg1;

	if(![arg1.subviews containsObject:self.batteryView]) {
		//[newView addSubview:self.batteryView];
		[newView addArrangedSubview:self.batteryView];
	}
	newView.frame = CGRectMake(newView.frame.origin.x, newView.frame.origin.y, newView.frame.size.width, newView.frame.size.height + self.batteryView.frame.size.height);
	original = newView.frame;
	%orig(newView);
}

%new
-(void)KaiUpdate {
	NSLog(@"Kai: Updating Pos.");

	dispatch_async(dispatch_get_main_queue(), ^{

	[UIView animateWithDuration:0.3 animations:^{

	self.batteryView.frame = CGRectMake(UIScreen.mainScreen.bounds.origin.x, 0, UIScreen.mainScreen.bounds.size.width, (self.batteryView.number * 85));
	self.batteryView.hidden = YES;
	self.batteryView.hidden = NO;
	//self.batteryView.superview.frame = CGRectMake(original.origin.x, original.origin.y, original.size.width, original.size.height + (self.batteryView.number * 85));

	}];
	[self.batteryView darkLightMode];
	});

}

%new
-(void)KaiInfo {
	NSLog(@"Kai: Updating Info");
	[self.batteryView updateBattery];
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
