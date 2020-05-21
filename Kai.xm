#import "Kai.h"

%hook KAITarget //This class is defined in %ctor, KAITarget is not a class name.

%property (nonatomic, assign) BOOL hasKai;

-(void)_layoutStackView {

	NSInteger lastSlot = [[self stackView].subviews count] -1;
	//this code is used to determine if kai is at the bottom of the stack view
	if([[self stackView].subviews objectAtIndex:lastSlot] != [KAIBattery sharedInstance] && belowMusic) {
		//if it is not, but the option to have kai below music is on, i simply remove from it's current pos. 
		//and insert into last slot.
		[[self stackView] removeArrangedSubview:[KAIBattery sharedInstance]];
		[[self stackView] insertArrangedSubview:[KAIBattery sharedInstance] atIndex:lastSlot];
	}
	
	//makes kai lay itself out when the stack does
	[self KaiUpdate];

	%orig;
}

-(void)setStackView:(UIStackView *)arg1 {

	if(!KAISelf.hasKai) {
		KAIBattery *battery = [[KAIBattery alloc] init];

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
	KAIBattery *battery = [KAIBattery sharedInstance];

	[UIView animateWithDuration:0.3 animations:^{

		if(!battery.heightConstraint) {
			
			battery.heightConstraint.active = NO;
			battery.heightConstraint = [battery.heightAnchor constraintEqualToConstant:85];
			//set an initial constraint
			battery.heightConstraint.active = YES;

		} else {
		int height = ((battery.number * (bannerHeight + spacing)) - spacing + 5); //big brain math
			battery.heightConstraint.active = NO;
			battery.heightConstraint.constant = height;
			battery.heightConstraint.active = YES;

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
		[UIView animateWithDuration:0.3 animations:^{

			//nice fade out
			[KAIBattery sharedInstance].alpha = 0;

		} completion:^(BOOL finished){

			[[KAIBattery sharedInstance] updateBattery];
			[self KaiUpdate];
			[UIView animateWithDuration:0.35 animations:^{
				//fade back in
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

	//Posts a notification to self when these keys change
	[self addObserver:self forKeyPath:@"charging" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"batterySaverModeActive" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"percentCharge" options:NSKeyValueObservingOptionNew context:nil];

	return %orig;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	dispatch_async(dispatch_get_main_queue(), ^{
		//sends the noti to update battery info
		[[NSNotificationCenter defaultCenter] postNotificationName:@"KaiInfoChanged" object:nil userInfo:nil];
	});
	
}
%end

%hook CSCoverSheetViewController

-(void)_transitionChargingViewToVisible:(BOOL)arg1 showBattery:(BOOL)arg2 animated:(BOOL)arg3 {
	if(hideChargingAnimation) {
		//Yeah bro this just makes the method never call to show the charging thing
		%orig(NO,NO,NO);
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
	if(enabled) {
    	%init(KAITarget = cls);
	}
}
