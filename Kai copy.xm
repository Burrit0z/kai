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

@interface CSCoverSheetViewBase : UIView
@property (nonatomic, strong) KAIBattery *battery;
-(void)KaiUpdate;
-(void)KaiInit;
@end

@interface SBCoverSheetPrimarySlidingViewController
-(void)KaiUpdate;
@end

@interface CSMainPageView : UIView
-(void)updateForPresentation:(id)arg1;
@end

@interface _CSSingleBatteryChargingView : UIView
@end

@interface NCNotificationListView : UIView
@property (nonatomic, assign) BOOL hasKai;
@property (nonatomic, assign) NSInteger previousKaiCount;
@end

BOOL setFrame = NO;
NCNotificationListView *batteryWidgetController;
KAIBattery *batteryWidget;
CSCoverSheetViewBase *base;
CGRect original;
CGRect originalBattery;

/*
- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context*/


/*
%hook BCBatterDeviceController

+(id)sharedInstance {
	[%orig addObserver:self forKeyPath:@"sortedDevices" options:NSKeyValueObservingOptionNew context:nil];
	return %orig;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
 
    if ([keyPath isEqualToString:@"sortedDevices"]) {
		[[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.apple.weather" suspended:NO];
    }

 
}

%end*/

%hook CSMainPageView

-(void)updateForPresentation:(id)arg1 {
	if(!setFrame) {
		if([self.subviews count] > 0) {
			CSCoverSheetViewBase *base = [self.subviews objectAtIndex:0];
			[base KaiInit];
		}
	}
	//[base KaiUpdate];
}
%end

%hook SBCoverSheetPrimarySlidingViewController 

-(void)viewWillAppear:(BOOL)arg1 {
	%orig;
	[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(KaiUpdate)
			name:@"KaiInfoChanged"
			object:nil];

	//[self KaiUpdate];

}

%new
-(void)KaiUpdate {
	[batteryWidget updateBattery];
	[base KaiUpdate];
}
%end


%hook CSCoverSheetViewBase
%property (nonatomic, strong) KAIBattery *battery;

-(void)traitCollectionDidChange:(id)arg1 {
	%orig;
	[batteryWidget darkLightMode];
}

-(void)setNeedsLayout {
	%orig;
	//[self KaiUpdate];
}

%new
-(void)KaiInit {
	if(!setFrame) {
		NCNotificationListView *scroller;
		if([self.subviews count] > 1) {
			UIView *temp = [self.subviews objectAtIndex:1];
			if([temp.subviews count] > 0) {
			scroller = [[temp.subviews objectAtIndex:0].subviews objectAtIndex:0];
			base = self;
			}
		}
		/*UIView *notiView;
		if([self.subviews count] > 0) {
			notiView = [self.subviews objectAtIndex:0];
		}*/
		original = scroller.frame;
		KAIBattery *battery = [[KAIBattery alloc] initWithFrame:CGRectMake(8, 0, self.frame.size.width - 16, self.frame.size.height)];
		originalBattery = battery.frame;
		[scroller addSubview:battery];
		setFrame = YES;
		batteryWidgetController = scroller;
		batteryWidget = battery;
		batteryWidgetController.previousKaiCount = 0;
	}
	[self KaiUpdate];
	[batteryWidget darkLightMode];
}

%new 
-(void)KaiUpdate {
	dispatch_async(dispatch_get_main_queue(), ^{

	[UIView animateWithDuration:0.3 animations:^{
		/*UIView *notiView;
		if([self.subviews count] > 0) {
			notiView = [self.subviews objectAtIndex:0];
		}*/

		batteryWidgetController.translatesAutoresizingMaskIntoConstraints = NO;

		/*for(UIView *view in batteryWidgetController.subviews) {
		view.bounds = CGRectMake(
				view.bounds.origin.x,
				view.bounds.origin.y - (batteryWidget.number * 85) + (batteryWidgetController.previousKaiCount * 85),
				view.bounds.size.width,
				view.bounds.size.height
			);
		}
		batteryWidgetController.previousKaiCount = batteryWidget.number;*/
	[batteryWidgetController.topAnchor constraintEqualToAnchor:batteryWidgetController.superview.topAnchor constant:(batteryWidget.number * 85)].active = YES;

	batteryWidget.frame = CGRectMake(
		originalBattery.origin.x,
		originalBattery.origin.y - (batteryWidget.number * 85),
		originalBattery.size.width,
		originalBattery.size.height
	);
	}];
	[batteryWidget darkLightMode];
	});
}
%end


%hook NCNotificationListView
%property (nonatomic, assign) BOOL hasKai;
%property (nonatomic, assign) NSInteger previousKaiCount;

//-(void)setBounds:(CGRect)arg1 {
	/*if(batteryWidgetController==self) {
		arg1 = (CGRectMake(
					original.origin.x,
					original.origin.y - (batteryWidget.number * 85),
					original.size.width,
					original.size.height
				));

				batteryWidget.frame = CGRectMake(
					originalBattery.origin.x,
					originalBattery.origin.y - (batteryWidget.number * 85),
					originalBattery.size.width,
					originalBattery.size.height
				);

				[batteryWidget darkLightMode];
	}*/

//	%orig;
//}

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
