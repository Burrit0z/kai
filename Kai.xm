#import "Kai.h"

CSAdjunctListView *list;

%group main

%hook SBMediaController

- (BOOL)isPlaying {
	Class cls = kCFCoreFoundationVersionNumber > 1600 ? ([objc_getClass("CSAdjunctListView") class]) : ([objc_getClass("SBDashBoardAdjunctListView") class]);
	BOOL playing = %orig;

	if(!removeForMedia) {
		[cls reorderKai];
		return playing;
	}

	// if removeForMedia
	if(self.nowPlayingApplication && shouldBeAdded) {
		// a valid playing app, and it was shown
		shouldBeAdded = NO;

		[[KAIBatteryPlatter sharedInstance] removeFromSuperview];
		[[[cls sharedListViewForKai] stackView] removeArrangedSubview:[KAIBatteryPlatter sharedInstance]];

		return playing;
	} else if(!playing && self.nowPlayingApplication == nil) {
		// not playing and the app is nil
		shouldBeAdded = YES;

		// if we don't want to hide kai, fix its order
		[cls reorderKai];
	}

	return playing;
}

%end

%hook KAITarget // This class is defined in %ctor, KAITarget is not a class name.

%property (nonatomic, assign) BOOL hasKai;

- (void)setClipsToBounds:(BOOL)arg1 {
    %orig(YES);
}

- (void)setStackView:(UIStackView *)arg1 {
	KAISelf.clipsToBounds = YES;

	if(!KAISelf.hasKai) {

		list = self;

		KAIBatteryPlatter *battery = [[KAIBatteryPlatter alloc] initWithFrame:[self stackView].frame];

		// Add noti observer
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(KaiInfo)
			name:@"KaiInfoChanged"
			object:nil];
		KAISelf.hasKai = YES;

	if(![arg1.subviews containsObject:battery]) { //  if not added
		// add kai to the stack view
		[arg1 addArrangedSubview:battery];
	}
	[battery updateBattery];

	// send the adjusted stackview as arg1
	%orig(arg1);

	}
}

%new
- (void)KaiInfo {

	if(!isUpdating) {

		isUpdating = YES;

		dispatch_async(dispatch_get_main_queue(), ^{

		[[KAIBatteryPlatter sharedInstance] updateBattery];
		if([KAIBatteryPlatter sharedInstance].number == 0) {
			[[KAIBatteryPlatter sharedInstance] removeFromSuperview];
			[[self stackView] removeArrangedSubview:[KAIBatteryPlatter sharedInstance]];
		} else if(![[self stackView].subviews containsObject:[KAIBatteryPlatter sharedInstance]] && shouldBeAdded) {
			[[self stackView] addSubview:[KAIBatteryPlatter sharedInstance]];
			[[self stackView] addArrangedSubview:[KAIBatteryPlatter sharedInstance]];
		}
		if([KAISelf.superview respondsToSelector:@selector(fixComplicationsViewFrame)]) {
		[KAISelf.superview performSelector:@selector(fixComplicationsViewFrame) withObject:KAISelf.superview afterDelay:0.35];
		}

		isUpdating = NO;
		});

	}

}

%new
+ (id)sharedListViewForKai {
	return list;
}

%new
+ (void)reorderKai {
	NSLog(@"[Kai]: Reordering kai");
	UIStackView *stack = [[self sharedListViewForKai] stackView];
	if(belowMusic) { // cursed
		[stack removeArrangedSubview:[KAIBatteryPlatter sharedInstance]];
		[stack addArrangedSubview:[KAIBatteryPlatter sharedInstance]];
	} else {
		[stack removeArrangedSubview:[KAIBatteryPlatter sharedInstance]];
		[stack insertArrangedSubview:[KAIBatteryPlatter sharedInstance] atIndex:0];
	}
}

%end

%hook SBCoverSheetPrimarySlidingViewController

- (void)viewDidDisappear:(BOOL)animated {
	if(reAlignSelf)
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KaiResetOffset" object:nil userInfo:nil];
	%orig;
}

- (void)viewDidAppear:(BOOL)animated {
	if(reAlignSelf)
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KaiResetOffset" object:nil userInfo:nil];
	%orig;
}

%end

%hook BCBatteryDevice
%property (nonatomic, strong) KAIBatteryCell *kaiCell;

- (void)setCharging:(BOOL)arg1 {
	// sends the noti to update battery info
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KaiInfoChanged" object:nil userInfo:nil];
	%orig;
}

- (void)setBatterySaverModeActive:(BOOL)arg1 {
	// sends the noti to update battery info
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KaiInfoChanged" object:nil userInfo:nil];
	%orig;
}

- (void)setPercentCharge:(NSInteger)arg1 {
	// sends the noti to update battery info
	if(arg1 != 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"KaiInfoChanged" object:nil userInfo:nil];
	}
	%orig;
}

- (void)dealloc {
	%orig;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KaiInfoChanged" object:nil userInfo:nil];
}

%new
- (id)kaiCellForDevice {
	if(self && self.kaiCell == nil) {
		self.kaiCell = [[KAIBatteryCell alloc] initWithFrame:CGRectMake(0,0,[KAIBatteryPlatter sharedInstance].frame.size.width,0) device:self]; }
		((KAIBatteryCell *)self.kaiCell).translatesAutoresizingMaskIntoConstraints = NO;
		[(KAIBatteryCell *)self.kaiCell updateInfo];

	return self.kaiCell;
}

%new
- (void)resetKaiCellForNewPrefs {
	self.kaiCell = [[KAIBatteryCell alloc] initWithFrame:CGRectMake(0,0,[KAIBatteryPlatter sharedInstance].frame.size.width,0) device:self];
		((KAIBatteryCell *)self.kaiCell).translatesAutoresizingMaskIntoConstraints = NO;
		[(KAIBatteryCell *)self.kaiCell updateInfo];
}
%end

%hook KAICSTarget // Again, not a class

- (void)_transitionChargingViewToVisible:(BOOL)arg1 showBattery:(BOOL)arg2 animated:(BOOL)arg3 {
	if(hideChargingAnimation) {
		// Yeah bro this just makes the method never call to show the charging thing
		%orig(NO,NO,NO);
	} else {
		%orig(arg1, arg2, arg3);
	}
}

- (void)_transitionChargingViewToVisible:(BOOL)arg1 showBattery:(BOOL)arg2 animated:(BOOL)arg3 force:(BOOL)arg4 { // might just be ios12
	if(hideChargingAnimation) {
		// Same idea
		%orig(NO,NO,NO,NO);
	} else {
		%orig(arg1, arg2, arg3, arg4);
	}
}

%end

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

	// Bro Muirey helped me figure out a logical way to do this because iOS 12-13 classes have changed

	Class cls = kCFCoreFoundationVersionNumber > 1600 ? %c(CSAdjunctListView) : %c(SBDashBoardAdjunctListView);

	Class CSCls = kCFCoreFoundationVersionNumber > 1600 ? %c(CSCoverSheetViewController) : %c(SBDashBoardViewController);

	if(kCFCoreFoundationVersionNumber < 1740) {
		ios13 = YES; // wow very pog version you have
	}

	if(enabled) {
		%init(main, KAITarget = cls, KAICSTarget = CSCls); // BIG BRAIN BRO!!
	}

	NSLog(@"[kai]: loaded into %@", [NSBundle mainBundle].bundleIdentifier);
}
