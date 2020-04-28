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

@interface CSMainPageView : UIView
@property (nonatomic, strong) KAIBattery *battery;
-(void)updateForPresentation:(id)arg1;
-(void)KaiUpdate;
@end


BOOL setFrame = NO;
CSMainPageView *batteryWidget;
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

%hook SBCoverSheetPrimarySlidingViewController 

-(void)viewWillAppear:(BOOL)arg1 {
	%orig;
	[batteryWidget.battery updateBattery];
	[batteryWidget KaiUpdate];

}
/*
-(void)viewWillDisappear:(BOOL)arg1 {
	%orig;
	[batteryWidget.battery updateBattery];
	[batteryWidget KaiUpdate];
}*/
%end


%hook CSMainPageView
%property (nonatomic, strong) KAIBattery *battery;

-(void)updateForPresentation:(id)arg1 {
	%orig;
	if(!setFrame) {
		original = self.frame;
		self.battery = [[KAIBattery alloc] initWithFrame:CGRectMake(8, self.frame.origin.y + 150, self.frame.size.width - 16, self.frame.size.height)];
		originalBattery = self.battery.frame;
		[self addSubview:self.battery];
		setFrame = YES;
		batteryWidget = self;
	}
	[self.battery updateBattery];
	[self KaiUpdate];

}

%new 
-(void)KaiUpdate {
	self.frame = CGRectMake(
			original.origin.x,
			original.origin.y + (self.battery.number * 85),
			original.size.width,
			original.size.height
		);

	self.battery.frame = CGRectMake(
		originalBattery.origin.x,
		originalBattery.origin.y - (self.battery.number * 85) + 85,
		originalBattery.size.width,
		originalBattery.size.height
	);
}
%end