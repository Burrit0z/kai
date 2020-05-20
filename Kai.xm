#import "Kai.h"

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

	UIStackView *newView = arg1;

	if(![arg1.subviews containsObject:battery]) {
		[newView addArrangedSubview:battery];
	}

	%orig(newView);

	}
}

%new
-(void)KaiUpdate {
	KAIBattery *battery = [KAIBattery sharedInstance];

	[UIView animateWithDuration:0.3 animations:^{

		if(!battery.heightConstraint) {
			
			battery.heightConstraint.active = NO;
			NSLog(@"kai: 1st time, assigning to %d", 500);
			battery.heightConstraint = [battery.heightAnchor constraintEqualToConstant:500];
			battery.heightConstraint.active = YES;

		} else {
		int height = (battery.number * (bannerHeight + spacing));
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
	if(!isUpdating) {
		isUpdating = YES;
		[UIView animateWithDuration:0.3 animations:^{
			[KAIBattery sharedInstance].alpha = 0;
		} completion:^(BOOL finished){
			[[KAIBattery sharedInstance] updateBattery];
			[self KaiUpdate];
			[UIView animateWithDuration:0.35 animations:^{
				[KAIBattery sharedInstance].alpha = 1;
			} completion:^(BOOL finished){
				isUpdating = NO;
			}];
		}];
	}
}
%end


%hook BCBatteryDevice

- (id)initWithIdentifier:(id)arg1 vendor:(long long)arg2 productIdentifier:(long long)arg3 parts:(unsigned long long)arg4 matchIdentifier:(id)arg5 {

	[self addObserver:self forKeyPath:@"charging" options:NSKeyValueObservingOptionNew context:nil];
	//[self addObserver:self forKeyPath:@"powerSourceState" options:NSKeyValueObservingOptionNew context:nil];
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

%hook CSBatteryChargingView

+(id)batteryChargingViewWithSingleBattery {
	//NSLog(@"kai: here bro: %@", [NSThread callStackSymbols]);
	//[UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"kai: here bro: %@", [NSThread callStackSymbols]];
	return nil;
}

+(id)batteryChargingViewWithDoubleBattery {
	return nil;
}

-(CGFloat)desiredVisibilityDuration {
	return 0;
}

-(void)setBatteryVisible:(BOOL)arg1 {
	%orig(NO);
}

%end

%ctor {
	preferencesChanged();
	CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(),
        &observer,
        (CFNotificationCallback)applyPrefs,
        kSettingsChangedNotification,
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately
    );
	Class cls = kCFCoreFoundationVersionNumber > 1600 ? ([objc_getClass("CSAdjunctListView") class]) : ([objc_getClass("SBDashBoardAdjunctListView") class]);
	if(enabled) {
    	%init(KAITarget = cls);
	}
}
