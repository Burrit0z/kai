#import "Kai.h"

%group main

%hook KAITarget //This class is defined in %ctor, KAITarget is not a class name.

%property (nonatomic, assign) BOOL hasKai;

-(void)_layoutStackView {

	NSInteger lastSlot = [[self stackView].subviews count] -1;
	//this code is used to determine if kai is at the bottom of the stack view
	if([[self stackView].subviews objectAtIndex:lastSlot] != [KAIBatteryPlatter sharedInstance] && belowMusic) {
		//if it is not, but the option to have kai below music is on, i simply remove from it's current pos. 
		//and insert into last slot.
		[[self stackView] removeArrangedSubview:[KAIBatteryPlatter sharedInstance]];
		[[self stackView] insertArrangedSubview:[KAIBatteryPlatter sharedInstance] atIndex:lastSlot];
	}

	if([KAISelf.superview respondsToSelector:@selector(fixComplicationsViewFrame)]) {
        [(NCNotificationListView *)(KAISelf.superview) fixComplicationsViewFrame];
    }

	[[KAIBatteryPlatter sharedInstance] setNumber:[KAIBatteryPlatter sharedInstance].number];

	%orig;
}

-(void)setStackView:(UIStackView *)arg1 {

	if(!KAISelf.hasKai) {
		KAIBatteryPlatter *battery = [[KAIBatteryPlatter alloc] initWithFrame:[self stackView].frame];

		//Add noti observer
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(KaiInfo)
			name:@"KaiInfoChanged"
			object:nil];
		KAISelf.hasKai = YES;

	if(![arg1.subviews containsObject:battery]) { //if not added
		//add kai to the stack view
		[arg1 addArrangedSubview:battery];
	}
	[battery updateBattery];

	//send the adjusted stackview as arg1 
	%orig(arg1);

	}
}

%new
-(void)KaiInfo {

	if(!isUpdating) {

		isUpdating = YES;

		//NSLog(@"kai: kai info will update");
		dispatch_async(dispatch_get_main_queue(), ^{

		[[KAIBatteryPlatter sharedInstance] updateBattery];
		if([KAIBatteryPlatter sharedInstance].number == 0) {
			[[KAIBatteryPlatter sharedInstance] removeFromSuperview];
			[[self stackView] removeArrangedSubview:[KAIBatteryPlatter sharedInstance]];
		} else if(![[self stackView].subviews containsObject:[KAIBatteryPlatter sharedInstance]]) {
			[[self stackView] addSubview:[KAIBatteryPlatter sharedInstance]];
			[[self stackView] addArrangedSubview:[KAIBatteryPlatter sharedInstance]];
		}
		if([KAISelf.superview respondsToSelector:@selector(fixComplicationsViewFrame)]) {
		[KAISelf.superview performSelector:@selector(fixComplicationsViewFrame) withObject:KAISelf.superview afterDelay:0.35];
		//[KAISelf.superview performSelector:@selector(fixComplicationsViewFrame) withObject:KAISelf.superview afterDelay:0.5];
		}

		isUpdating = NO;
		});

	}

}
%end


%hook BCBatteryDevice
%property (nonatomic, strong) KAIBatteryCell *kaiCell;

- (id)initWithIdentifier:(id)arg1 vendor:(long long)arg2 productIdentifier:(long long)arg3 parts:(unsigned long long)arg4 matchIdentifier:(id)arg5 {

	//Posts a notification to self when these keys change
	[self addObserver:self forKeyPath:@"charging" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"batterySaverModeActive" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"percentCharge" options:NSKeyValueObservingOptionNew context:nil];

	return %orig;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	//if([self isMemberOfClass:[objc_getClass("BCBatteryDevice") class]] && [self respondsToSelector:@selector(_kaiCell)] && object == self && ([keyPath isEqualToString:@"charging"] || [keyPath isEqualToString:@"percentCharge"] || [keyPath isEqualToString:@"batterySaverModeActive"])) {

		//sends the noti to update battery info
		[[NSNotificationCenter defaultCenter] postNotificationName:@"KaiInfoChanged" object:nil userInfo:nil];
	//}
	
}

%new
-(id)kaiCellForDevice {
	if(self && self.kaiCell == nil) {
		self.kaiCell = [[KAIBatteryCell alloc] initWithFrame:CGRectMake(0,0,[KAIBatteryPlatter sharedInstance].frame.size.width,0) device:self]; }
		((KAIBatteryCell *)self.kaiCell).translatesAutoresizingMaskIntoConstraints = NO;
		[(KAIBatteryCell *)self.kaiCell updateInfo];

	return self.kaiCell;
}

%new
-(void)resetKaiCellForNewPrefs {
	self.kaiCell = [[KAIBatteryCell alloc] initWithFrame:CGRectMake(0,0,[KAIBatteryPlatter sharedInstance].frame.size.width,0) device:self]; 
		((KAIBatteryCell *)self.kaiCell).translatesAutoresizingMaskIntoConstraints = NO;
		[(KAIBatteryCell *)self.kaiCell updateInfo];
}
%end

%hook KAICSTarget //Again, not a class

-(void)_transitionChargingViewToVisible:(BOOL)arg1 showBattery:(BOOL)arg2 animated:(BOOL)arg3 {
	if(hideChargingAnimation) {
		//Yeah bro this just makes the method never call to show the charging thing
		%orig(NO,NO,NO);
	}
}

-(void)_transitionChargingViewToVisible:(BOOL)arg1 showBattery:(BOOL)arg2 animated:(BOOL)arg3 force:(BOOL)arg4 { //might just be ios12
	if(hideChargingAnimation) {
		//Same idea
		%orig(NO,NO,NO,NO);
	}
}

%end

%end

%group drm 

%hook SBIconController

-(void)viewDidAppear:(BOOL)arg1 {

	%orig;

	UIAlertController* alert2 = [UIAlertController alertControllerWithTitle:@"kai"
					message:@"Woops! Chariz is saying your device has not purchased Multipla! You must have purchased Multipla to use the kai beta. Please make sure to link your device to your Chariz account!"
					preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* yes = [UIAlertAction actionWithTitle:@"I understand" style:UIAlertActionStyleDestructive
	handler:^(UIAlertAction * action) {
	}];
	[alert2 addAction:yes];
	[self presentViewController:alert2 animated:YES completion:nil];

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

	//Bro Muirey helped me figure out a logical way to do this because iOS 12-13 classes have changed
	Class cls = kCFCoreFoundationVersionNumber > 1600 ? ([objc_getClass("CSAdjunctListView") class]) : ([objc_getClass("SBDashBoardAdjunctListView") class]);

	Class CSCls = kCFCoreFoundationVersionNumber > 1600 ? ([objc_getClass("CSCoverSheetViewController") class]) : ([objc_getClass("SBDashBoardViewController") class]);

	//BOOL bypass = YES;
	BOOL bypass = NO;

	if(([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/xyz.burritoz.thomz.multipla.list"] && [[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/xyz.burritoz.thomz.multipla.md5sums"]) || bypass) {
    	%init(main, KAITarget = cls, KAICSTarget = CSCls); //BIG BRAIN BRO!!
	} else if(!bypass && !([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/xyz.burritoz.thomz.multipla.list"] && [[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/xyz.burritoz.thomz.multipla.md5sums"])) {
		//if(0==1)
		%init(drm);
	}
}
