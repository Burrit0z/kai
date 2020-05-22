#import "Kai.h"

%hook KAITarget //This class is defined in %ctor, KAITarget is not a class name.

%property (nonatomic, assign) BOOL hasKai;

-(void)_layoutStackView {

	NSInteger lastSlot = [[self stackView].subviews count] -1;
	//this code is used to determine if kai is at the bottom of the stack view
	if([[self stackView].subviews objectAtIndex:lastSlot] != [KAIBatteryStack sharedInstance] && belowMusic) {
		//if it is not, but the option to have kai below music is on, i simply remove from it's current pos. 
		//and insert into last slot.
		[[self stackView] removeArrangedSubview:[KAIBatteryStack sharedInstance]];
		[[self stackView] insertArrangedSubview:[KAIBatteryStack sharedInstance] atIndex:lastSlot];
	}
	
	//makes kai lay itself out when the stack does
	NSLog(@"kai: laying out stack view");
	[self KaiUpdate];

	%orig;
}

-(void)setStackView:(UIStackView *)arg1 {

	if(!KAISelf.hasKai) {
		KAIBatteryStack *battery = [[KAIBatteryStack alloc] init];

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

	//send the adjusted stackview as arg1 
	%orig(arg1);

	}
}

%new
-(void)KaiUpdate {
	KAIBatteryStack *battery = [KAIBatteryStack sharedInstance];
	battery.number = [battery.subviews count];

	[UIView animateWithDuration:0.3 animations:^{

		if(!battery.heightConstraint) {
			
			battery.heightConstraint.active = NO;
			battery.heightConstraint = [battery.heightAnchor constraintEqualToConstant:85];
			//set an initial constraint
			battery.heightConstraint.active = YES;

		} else {
		int height = (battery.number * (bannerHeight + spacing)); //big brain math
			battery.heightConstraint.active = NO; //deactivation
			battery.heightConstraint.constant = height;
			battery.heightConstraint.active = YES; //forcing reactivation

			UIStackView *s = [self stackView];
			s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, (s.frame.size.height - 1));
			//literally does nothing but makes the stack view lay itself out (doesnt adjust frame because translatesAutoreszingMaskIntoConstraints = NO on stack views)
		}

	}];
	
}

%new
-(void)KaiInfo {

	if(!isUpdating) {

		isUpdating = YES;

		//NSLog(@"kai: kai info will update");
		dispatch_async(dispatch_get_main_queue(), ^{

		[[KAIBatteryStack sharedInstance] updateBattery];
		[self KaiUpdate];

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
	if(self && self.kaiCell == nil) {
		self.kaiCell = [[KAIBatteryCell alloc] initWithFrame:CGRectMake(0,0,0,0) device:self]; }
		((KAIBatteryCell *)self.kaiCell).translatesAutoresizingMaskIntoConstraints = NO;
		[((KAIBatteryCell *)self.kaiCell).heightAnchor constraintEqualToConstant:bannerHeight].active = YES;
	dispatch_async(dispatch_get_main_queue(), ^{
		//sends the noti to update battery info
		[[NSNotificationCenter defaultCenter] postNotificationName:@"KaiInfoChanged" object:nil userInfo:nil];
		[(KAIBatteryCell *)self.kaiCell updateInfo];

		BOOL shouldAdd = NO;

		if(showAll) {
			shouldAdd = YES;
		} else if(!showAll && self.charging) {
			shouldAdd = YES;
		}

		if(![[KAIBatteryStack sharedInstance].subviews containsObject:self.kaiCell] && shouldAdd) {
			[[KAIBatteryStack sharedInstance] addArrangedSubview:self.kaiCell];
		} else if([[KAIBatteryStack sharedInstance].subviews containsObject:self.kaiCell] && !shouldAdd) {
			[[KAIBatteryStack sharedInstance] removeArrangedSubview:self.kaiCell];
		}

	});
	
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

	if(enabled) {
    	%init(KAITarget = cls, KAICSTarget = CSCls); //BIG BRAIN BRO!!
	}
}
