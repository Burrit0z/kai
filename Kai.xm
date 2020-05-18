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
@property (nonatomic, strong) KAIBattery *battery;
@property (nonatomic, assign) BOOL hasKai;
@property (nonatomic, assign) NSInteger previousKaiCount;
-(void)KaiUpdate;
@end

@interface CSMainPageView : UIView
-(void)updateForPresentation:(id)arg1;
@end

@interface _CSSingleBatteryChargingView : UIView
@end

/*
@interface NCNotificationListView : UIView
@property (nonatomic, assign) BOOL hasKai;
@property (nonatomic, assign) NSInteger previousKaiCount;
@end*/

BOOL setFrame = NO;
CGRect original;
CGRect originalBattery;


%hook CSAdjunctListView
%property (nonatomic, strong) KAIBattery *battery;
%property (nonatomic, assign) BOOL hasKai;
%property (nonatomic, assign) NSInteger previousKaiCount;

-(id)initWithFrame:(CGRect)arg1 {
	original = self.frame;
		self.battery = [[KAIBattery alloc] initWithFrame:CGRectMake(8, 0, self.frame.size.width - 16, UIScreen.mainScreen.bounds.size.width)];
		originalBattery = self.battery.frame;
		[self addSubview:self.battery];
		setFrame = YES;
		self.previousKaiCount = 0;
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(KaiUpdate)
			name:@"KaiInfoChanged"
			object:nil];

	//[self KaiUpdate];
	[self.battery darkLightMode];

	return %orig;
}

%new
-(void)KaiUpdate {
	if(self.battery) {

			[self.battery updateBattery];

			dispatch_async(dispatch_get_main_queue(), ^{

			[UIView animateWithDuration:0.3 animations:^{

			self.translatesAutoresizingMaskIntoConstraints = NO;
			[self.topAnchor constraintEqualToAnchor:self.superview.topAnchor constant:(self.battery.number * 85)].active = YES;

			self.battery.frame = CGRectMake(
				originalBattery.origin.x,
				originalBattery.origin.y - (self.battery.number * 85),
				originalBattery.size.width,
				originalBattery.size.height
			);
			}];
			[self.battery darkLightMode];
			});

	}
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
