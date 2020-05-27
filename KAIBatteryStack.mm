#import "KAIBatteryStack.h"

KAIBatteryStack *instance;
NSTimer *queueTimer = nil;
//NSMutableArray *showingCells = [[NSMutableArray alloc] init];

@implementation KAIBatteryStack

-(instancetype)init {
    self = [super init];
    instance = self;
    if (self) {
        self.displayingDevices = [[NSMutableArray alloc] init];
        self.axis = 1;
        self.distribution = 0;
        self.spacing = 0;
        self.alignment = 0;
        self.oldCountOfDevices = -100;
        self.queued = NO;
        [self updateBattery];
        //self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
    }
    return self;
}

long long batteryPercentage;
long long lastPercentage;

-(void)updateBattery {
    dispatch_async(dispatch_get_main_queue(), ^{
        BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
        NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");
    
    /*if(self.oldCountOfDevices == -100) {
        self.oldCountOfDevices = [devices count] + 1;
    }
    self.oldCountOfDevices = [devices count];

    for (BCBatteryDevice *device in devices) {
        KAIBatteryCell *cell = [device kaiCellForDevice];

        [cell updateInfo];
    }

    if(!self.isUpdating && self.oldCountOfDevices != 0 && ([devices count] + 1 == self.oldCountOfDevices || [devices count] - 1 == self.oldCountOfDevices || [devices count] == self.oldCountOfDevices)) {*/
    if(!self.isUpdating) {

    self.isUpdating = YES;

        
        for (BCBatteryDevice *device in devices) {
            KAIBatteryCell *cell = [device kaiCellForDevice];
            BOOL charging = MSHookIvar<long long>(device, "_charging");
            BOOL internal = MSHookIvar<BOOL>(device, "_internal");
            BOOL shouldAdd = NO;

            if(showAll) {
                shouldAdd = YES;
            } else if(showAllMinusInternal && !internal) {
                shouldAdd = YES;
            } else if(!showAll && charging) {
                shouldAdd = YES;
            }

            if(![self.subviews containsObject:cell] && shouldAdd && [devices containsObject:device]) {
                //[cell setFrame:CGRectMake(0,0,self.frame.size.width, bannerHeight)];
                cell.alpha = 0;
                [self addSubview:cell];
                [self addArrangedSubview:cell];
                [UIView animateWithDuration:0.3 animations:^{
                    cell.alpha = 1;
                }];
            } else if([self.subviews containsObject:cell] && !shouldAdd){
                [UIView animateWithDuration:0.3 animations:^{
                    cell.alpha = 0;
                } completion:^(BOOL finished) {
                    [cell removeFromSuperview];
                    [self removeArrangedSubview:cell];
                    cell.alpha = 1;
                }];
            }

        }

        for(KAIBatteryCell *cell in self.subviews) {
            if(![devices containsObject:cell.device]) {
                [UIView animateWithDuration:0.3 animations:^{
                    cell.alpha = 0;
                } completion:^(BOOL finished) {
                    [cell removeFromSuperview];
                    [self removeArrangedSubview:cell];
                    cell.alpha = 1;
                }];
            }
        }

         //queueTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dispatchQueue) userInfo:nil repeats:NO];
        self.isUpdating = NO;

        } else if(self.isUpdating) {
            self.queued = YES;
        }

        self.number = [self.subviews count];

    [UIView animateWithDuration:0.3 animations:^{

		if(!self.heightConstraint) {
			
			self.heightConstraint.active = NO;
			self.heightConstraint = [self.heightAnchor constraintEqualToConstant:(self.number * (bannerHeight + spacing))];
			//set an initial constraint
			self.heightConstraint.active = YES;

		} else {
		int height = (self.number * (bannerHeight + spacing)); //big brain math
			//self.heightConstraint.active = NO; //deactivation
			self.heightConstraint.constant = height;
			//self.heightConstraint.active = YES; //forcing reactivation

			UIStackView *s = (UIStackView *)(self.superview);
			s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, (s.frame.size.height - 1));
			//literally does nothing but makes the stack view lay itself out (doesnt adjust frame because translatesAutoreszingMaskIntoConstraints = NO on stack views)
		}

        }];

    });

}

-(void)addArrangedSubview:(UIView *)view {
    [super addArrangedSubview:view];
    self.number = [self.subviews count];

    [UIView animateWithDuration:0.3 animations:^{

		if(!self.heightConstraint) {
			
			self.heightConstraint.active = NO;
			self.heightConstraint = [self.heightAnchor constraintEqualToConstant:(self.number * (bannerHeight + spacing))];
			//set an initial constraint
			self.heightConstraint.active = YES;

		} else {
		int height = (self.number * (bannerHeight + spacing)); //big brain math
			//self.heightConstraint.active = NO; //deactivation
			self.heightConstraint.constant = height;
			//self.heightConstraint.active = YES; //forcing reactivation

			UIStackView *s = (UIStackView *)(self.superview);
			s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, (s.frame.size.height - 1));
			//literally does nothing but makes the stack view lay itself out (doesnt adjust frame because translatesAutoreszingMaskIntoConstraints = NO on stack views)
		}

        }];

    if(textColor==0) {
        KAIBatteryCell *cell = (KAIBatteryCell *)view;
        if(@available(iOS 12.0, *)) {
			if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                [cell.label setTextColor:[UIColor whiteColor]];
                [cell.percentLabel setTextColor:[UIColor whiteColor]];
            } else if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                [cell.label setTextColor:[UIColor blackColor]];
                [cell.percentLabel setTextColor:[UIColor blackColor]];   
            }
        }
    }
}

-(void)removeArrangedSubview:(UIView *)view {
    [super removeArrangedSubview:view];
    self.number = [self.subviews count];

    [UIView animateWithDuration:0.3 animations:^{

		if(!self.heightConstraint) {
			
			self.heightConstraint.active = NO;
			self.heightConstraint = [self.heightAnchor constraintEqualToConstant:(self.number * (bannerHeight + spacing))];
			//set an initial constraint
			self.heightConstraint.active = YES;

		} else {
		int height = (self.number * (bannerHeight + spacing)); //big brain math
			//self.heightConstraint.active = NO; //deactivation
			self.heightConstraint.constant = height;
			//self.heightConstraint.active = YES; //forcing reactivation

			UIStackView *s = (UIStackView *)(self.superview);
			s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, (s.frame.size.height - 1));
			//literally does nothing but makes the stack view lay itself out (doesnt adjust frame because translatesAutoreszingMaskIntoConstraints = NO on stack views)
		}

        }];
}

-(void)refreshForPrefs {
    for( UIView *view in self.subviews ) {
        @try {
            [view removeFromSuperview];
        } @catch (NSException *exception) {
            //Panik
        }
    }

    BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
        NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");
    for(BCBatteryDevice *device in devices) {
        [device resetKaiCellForNewPrefs];
    }

    [self updateBattery];
}

-(void)dispatchQueue {
    self.isUpdating = NO;
    if(self.queued) {
        [self updateBattery];
        self.queued = NO;
    }
    [queueTimer invalidate];
    queueTimer = nil;
}

+(KAIBatteryStack *)sharedInstance {
    return instance;
}

@end