#import "KAIBattery.h"

KAIBattery *instance;
@implementation KAIBattery

-(instancetype)init {
    self = [super init];
    instance = self;
    if (self) {
        /*self.translatesAutoresizingMaskIntoConstraints = NO;
        [self.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:8].active = YES;
        [self.topAnchor constraintEqualToAnchor:self.topAnchor constant:arg1.origin.y].active = YES;
        [self.widthAnchor constraintEqualToConstant:UIScreen.mainScreen.bounds.size.width - 16].active = YES;
        [self.heightAnchor constraintEqualToConstant:(self.number * 85)].active = YES;*/
        [self updateBattery];
        [self darkLightMode];
        self.userInteractionEnabled = NO;
        //[self addSubview:self.batteryLabel];
    }
    return self;
}

long long batteryPercentage;
long long lastPercentage;

-(void)updateBattery {
    dispatch_async(dispatch_get_main_queue(), ^{
    if(!self.isUpdating) {
    self.isUpdating = YES;
    self.number = 0;
    float y = 0;
    BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
            NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");

            for( UIView *view in self.subviews ) {
                @try {
                    [view removeFromSuperview];
                } @catch (NSException *exception) {
                    //Panik
                }
            }

            for (BCBatteryDevice *device in devices) {
                NSString *deviceName = MSHookIvar<NSString *>(device, "_name");
                double batteryPercentage = MSHookIvar<long long>(device, "_percentCharge");
                BOOL charging = MSHookIvar<long long>(device, "_charging");
                BOOL LPM = MSHookIvar<BOOL>(device, "_batterySaverModeActive");

                if(charging) {

                    /*UIVisualEffectView *blank;
                    if(@available(iOS 12.0, *)) {
                        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                            blank = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
                        } else {
                            blank = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
                        }
                    } else {
                        blank = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
                    }*/
                    MTMaterialView *blank = [[[objc_getClass("MTMaterialView") class] alloc] _initWithRecipe:1 configuration:1 initialWeighting:1 scaleAdjustment:nil];
                    //blank.recipeDynamic = NO; //makes it stay light
                    blank.frame = CGRectMake(0, 0 + y, self.superview.bounds.size.width - 16, 80);
                    blank.layer.masksToBounds = YES;
                    blank.layer.cornerRadius = 13;
                    //[blank setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1]];

                NSString *labelText = [NSString stringWithFormat:@"%@", deviceName];

                UILabel *label = [[UILabel alloc] init];
                    [label setFont:[UIFont systemFontOfSize:16]];
                [label setTextColor:[UIColor whiteColor]];
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.numberOfLines = 0;
                [label setText:labelText];

                _UIBatteryView *battery = [[_UIBatteryView alloc] init];
                battery.chargePercent = (batteryPercentage*0.01);
                UILabel *percentLabel = [[UILabel alloc] init];
                    battery.showsPercentage = NO;
                        [percentLabel setFont:[UIFont systemFontOfSize:14]];
                        [percentLabel setTextColor:[UIColor whiteColor]];
                        percentLabel.lineBreakMode = NSLineBreakByWordWrapping;
                        [percentLabel setTextAlignment:NSTextAlignmentRight];
                        percentLabel.numberOfLines = 0;
                        [percentLabel setText:[NSString stringWithFormat:@"%ld%%", (long)((NSInteger) batteryPercentage)]];
                if(charging) battery.chargingState = 1;
                battery.showsInlineChargingIndicator = YES;
                if(LPM) battery.saverModeActive = YES;
                if(kCFCoreFoundationVersionNumber > 1600) {
                    [battery setBodyColorAlpha:1.0];
                    [battery setPinColorAlpha:1.0];
                }

                UIImage *glyph = [device glyph];
                UIImageView *glyphView = [[UIImageView alloc] init];
                    glyphView.contentMode = UIViewContentModeScaleAspectFit;
                    [glyphView setImage:glyph];

                label.frame = CGRectMake(65.5,27.5 + y,275,25);
                glyphView.frame = CGRectMake(20.5,18.5 + y,40,40);
                battery.frame = CGRectMake(self.superview.bounds.size.width - 16 - 49,35 + y,20,10);
                percentLabel.frame = CGRectMake(self.superview.bounds.size.width - 16 - 94,35 + y,36,12);

            y+=85;
            self.number +=1;

            [self addSubview:blank];
            [self addSubview:percentLabel];
            [self addSubview:label];
            [self addSubview:battery];
            [self addSubview:glyphView];
            //blank.alpha = 0.8;
        }
    }
    //[self.heightAnchor constraintEqualToConstant:(self.number * 85)].active = YES;
    self.isUpdating = NO;
    [self darkLightMode];
    }
    });
}

+(KAIBattery *)sharedInstance {
    return instance;
}

-(void)darkLightMode {
    /*for(UIVisualEffectView *view in self.subviews) {
        if(@available(iOS 12.0, *)) {
		if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
			if([view respondsToSelector:@selector(setEffect:)]) view.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
		}
		else {
			if([view respondsToSelector:@selector(setEffect:)]) view.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		}
		}
    }*/
}

@end