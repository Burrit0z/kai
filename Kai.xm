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
	NSLog(@"Kai: Laying out stack view");
	//%orig;

	if(!self.hasKai) {
	//original = self.superview.superview.frame;
		KAIBattery *battery = [[KAIBattery alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
		battery.translatesAutoresizingMaskIntoConstraints = NO;
        [battery.leftAnchor constraintEqualToAnchor:battery.leftAnchor].active = YES;
        [battery.topAnchor constraintEqualToAnchor:battery.topAnchor].active = YES;
        [battery.widthAnchor constraintEqualToConstant:UIScreen.mainScreen.bounds.size.width].active = YES;
        [battery.heightAnchor constraintEqualToConstant:(battery.number * 85)].active = YES;
		originalBattery = battery.frame;
		original = self.frame;
		setFrame = YES;
		self.previousKaiCount = 0;
		self.hasKai = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(KaiInfo)
			name:@"KaiInfoChanged"
			object:nil];
	[[KAIBattery sharedInstance] darkLightMode];
	//CGRect frame = [self stackView].frame;
	//[[self stackView] setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + ([KAIBattery sharedInstance].number * 85))];
	//[self setStackView:[KAIBattery sharedInstance]];
	}

	//[[self stackView].heightAnchor constraintEqualToAnchor:[self stackView].heightAnchor constant:([KAIBattery sharedInstance].number * 85)].active = YES;
	//self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, original.size.height + ([KAIBattery sharedInstance].number * 85));

	[self KaiUpdate];

	%orig;
}

-(void)setStackView:(UIStackView *)arg1 {
	NSLog(@"Kai: Updating setting stack view");

	if(!self.hasKai) {
	//original = self.superview.superview.frame;
		KAIBattery *battery = [[KAIBattery alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height)];
		battery.translatesAutoresizingMaskIntoConstraints = NO;
        [battery.leftAnchor constraintEqualToAnchor:battery.leftAnchor].active = YES;
        [battery.topAnchor constraintEqualToAnchor:battery.topAnchor].active = YES;
        [battery.widthAnchor constraintEqualToConstant:UIScreen.mainScreen.bounds.size.width].active = YES;
        [battery.heightAnchor constraintEqualToConstant:(battery.number * 85)].active = YES;
		originalBattery = battery.frame;
		original = self.frame;
		setFrame = YES;
		self.previousKaiCount = 0;
		self.hasKai = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(KaiInfo)
			name:@"KaiInfoChanged"
			object:nil];
	[[KAIBattery sharedInstance] darkLightMode];
	//CGRect frame = [self stackView].frame;
	/*[[self stackView] setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + ([KAIBattery sharedInstance].number * 85))];*/
	//[self setStackView:[KAIBattery sharedInstance]];
	}

	UIStackView *newView = arg1;

	if(![arg1.subviews containsObject:[KAIBattery sharedInstance]]) {
		//[newView addSubview:[KAIBattery sharedInstance]];
		[newView addArrangedSubview:[KAIBattery sharedInstance]];
	}
	//newView.frame = CGRectMake(newView.frame.origin.x, newView.frame.origin.y, newView.frame.size.width, newView.frame.size.height + [KAIBattery sharedInstance].frame.size.height);
	//original = newView.frame;
	%orig(newView);
}

%new
-(void)KaiUpdate {
	/*NSLog(@"Kai: Updating Pos.");

	dispatch_async(dispatch_get_main_queue(), ^{

	[UIView animateWithDuration:0.3 animations:^{

	//[KAIBattery sharedInstance].frame = CGRectMake(UIScreen.mainScreen.bounds.origin.x, 0, UIScreen.mainScreen.bounds.size.width, ([KAIBattery sharedInstance].number * 85));
	//[KAIBattery sharedInstance].superview.frame = CGRectMake(original.origin.x, original.origin.y, original.size.width, original.size.height + ([KAIBattery sharedInstance].number * 85));

	}];
	[[KAIBattery sharedInstance] darkLightMode];
	});*/

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
