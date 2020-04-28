#include <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#include <stdio.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "KAIBattery.mm"
BOOL setFrame = NO;
KAIBattery *batteryWidget;
CGRect original;

/*
- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context*/


@interface UIApplication (Kai)
+(id)sharedApplication;
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface CSMainPageView : UIView
@property (nonatomic, strong) KAIBattery *battery;
-(void)updateForPresentation:(id)arg1;
@end
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

%hook SBCoverSheetPrimarySlidingViewController 

-(void)viewWillAppear:(BOOL)arg1 {
	%orig;
	[batteryWidget updateBattery];
}

%end


%hook CSMainPageView
%property (nonatomic, strong) KAIBattery *battery;

-(void)updateForPresentation:(id)arg1 {
	%orig;
	UIView *object = self;
	if(!setFrame) {
		original = self.frame;

		self.battery = [[KAIBattery alloc] initWithFrame:CGRectMake(8, 155, object.frame.size.width - 16, object.frame.size.height)];
		[self addSubview:self.battery];
		setFrame = YES;
		batteryWidget = self.battery;
	}

	object.frame = CGRectMake(
			original.origin.x,
			original.origin.y - (self.battery.number * 90),
			original.size.width,
			original.size.height + (self.battery.number * 90)
		);

	//[self.battery updateBattery];
/*
	NSArray* subViews = self.subviews;
            for( UIView *view in subViews ) {
				if([view isMemberOfClass:[objc_getClass("UILabel") class]] || [view isMemberOfClass:[objc_getClass("_UIBatteryView") class]] || [view isKindOfClass:[objc_getClass("UIImageView") class]]) {
					@try {
						[view removeFromSuperview];
					} @catch (NSException *exception) {
						//Panik
					}
				}
			}

	/*BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
            NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");
            for (BCBatteryDevice *device in devices) {
                NSString *deviceName = MSHookIvar<NSString *>(device, "_name");
                double batteryPercentage = MSHookIvar<long long>(device, "_percentCharge");
                BOOL charging = MSHookIvar<long long>(device, "_charging");
                BOOL LPM = MSHookIvar<BOOL>(device, "_batterySaverModeActive");
				if(charging) {

					NSString *labelText = [NSString stringWithFormat:@"%@", deviceName];

					UILabel *label = [[UILabel alloc] init];
					[label setFont:[UIFont systemFontOfSize:18]];
					[label setTextColor:[UIColor whiteColor]];
					label.lineBreakMode = NSLineBreakByWordWrapping;
					label.numberOfLines = 0;
					[label setText:labelText];

					[self addSubview:label];

					_UIBatteryView *battery = [[_UIBatteryView alloc] init];
					battery.chargePercent = (batteryPercentage*0.01);
					UILabel *percentLabel = [[UILabel alloc] init];
					//if(self.percentEnabled) {
				//		battery.showsPercentage = YES;
				//	} else {
						battery.showsPercentage = NO;
							[percentLabel setFont:[UIFont systemFontOfSize:14]];
							[percentLabel setTextColor:[UIColor whiteColor]];
							percentLabel.lineBreakMode = NSLineBreakByWordWrapping;
							[percentLabel setTextAlignment:NSTextAlignmentRight];
							percentLabel.numberOfLines = 0;
							[percentLabel setText:[NSString stringWithFormat:@"%ld%%", (long)((NSInteger) batteryPercentage)]];
							[self addSubview:percentLabel];
					//}
					if(charging) battery.chargingState = 2;
					if(LPM) battery.saverModeActive = YES;
					if(kCFCoreFoundationVersionNumber > 1600) {
						[battery setBodyColorAlpha:1.0];
						[battery setPinColorAlpha:1.0];
					}
					[self addSubview:battery];

					UIImage *glyph = [device glyph];
					UIImageView *glyphView = [[UIImageView alloc] init];
					//if(self.glyphsEnabled) {
						glyphView.contentMode = UIViewContentModeScaleAspectFit;
						[glyphView setImage:glyph];
						[self addSubview:glyphView];
					//}

					label.frame = CGRectMake(10,20,275,25);
					glyphView.frame = CGRectMake(27,25,17,15);
					battery.frame = CGRectMake(325,25,20,10);
					percentLabel.frame = CGRectMake(285,25,36,12);
				}
			}*/
}
%end