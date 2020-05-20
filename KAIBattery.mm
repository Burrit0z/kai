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

                BOOL shouldAdd = NO;

                if(showAll) {
                    shouldAdd = YES;
                } else if(!showAll && charging) {
                    shouldAdd = YES;
                }

                if(shouldAdd) {
                    UIView *blank;
                    if(bannerStyle==1) {
                        blank = [[[objc_getClass("MTMaterialView") class] alloc] _initWithRecipe:1 configuration:1 initialWeighting:1 scaleAdjustment:nil];
                    } else if(bannerStyle==2) {
                        blank = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
                    } else if(bannerStyle==3) {
                        blank = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
                    }
                    blank.layer.masksToBounds = YES;
                    blank.layer.continuousCorners = YES;
                    blank.layer.cornerRadius = cornerRadius;

                NSString *labelText = [NSString stringWithFormat:@"%@", deviceName];

                UILabel *label = [[UILabel alloc] init];
                if(!hideDeviceLabel) {
                    [label setFont:[UIFont systemFontOfSize:16]];
                } else if(hideDeviceLabel) {
                    [label setFont:[UIFont systemFontOfSize:0]];
                }
                [label setTextColor:[UIColor whiteColor]];
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.numberOfLines = 0;
                [label setText:labelText];

                _UIBatteryView *battery = [[_UIBatteryView alloc] init];
                battery.chargePercent = (batteryPercentage*0.01);
                UILabel *percentLabel = [[UILabel alloc] init];
                    battery.showsPercentage = NO;
                        if(hidePercent) {
                            [percentLabel setFont:[UIFont systemFontOfSize:0]];
                        } else {
                            [percentLabel setFont:[UIFont systemFontOfSize:14]];
                        }
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

                [self addSubview:blank];
                [self addSubview:percentLabel];
                [self addSubview:label];
                [self addSubview:battery];
                [self addSubview:glyphView];

                blank.translatesAutoresizingMaskIntoConstraints = NO;
                if(bannerAlign==2) { //center
                    [blank.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:horizontalOffset].active = YES;
                } else if(bannerAlign==1) { //left
                    [blank.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:horizontalOffset].active = YES;
                } else if(bannerAlign==3) { //right
                    [blank.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:horizontalOffset].active = YES;
                }
                [blank.topAnchor constraintEqualToAnchor:self.topAnchor constant:y].active = YES;
                [blank.widthAnchor constraintEqualToConstant:((self.superview.bounds.size.width - 16) + bannerWidthFactor)].active = YES;
                [blank.heightAnchor constraintEqualToConstant:bannerHeight].active = YES;


                //percentLabel.frame = CGRectMake(self.superview.bounds.size.width - 16 - 94,35 + y,36,12);
                percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
                [percentLabel.leftAnchor constraintEqualToAnchor:blank.rightAnchor constant:(- 94)].active = YES;
                [percentLabel.centerYAnchor constraintEqualToAnchor:blank.centerYAnchor].active = YES;
                [percentLabel.widthAnchor constraintEqualToConstant:35].active = YES;
                [percentLabel.heightAnchor constraintEqualToConstant:12].active = YES;

                //label.frame = CGRectMake(65.5,27.5 + y,275,25);
                label.translatesAutoresizingMaskIntoConstraints = NO;
                [label.leftAnchor constraintEqualToAnchor:glyphView.rightAnchor constant:4.5].active = YES;
                [label.centerYAnchor constraintEqualToAnchor:blank.centerYAnchor].active = YES;
                [label.rightAnchor constraintEqualToAnchor:percentLabel.leftAnchor constant:-4.5].active = YES;
                [label.heightAnchor constraintEqualToConstant:25].active = YES;

                //glyphView.frame = CGRectMake(20.5,18.5 + y,40,40);

                glyphView.translatesAutoresizingMaskIntoConstraints = NO;
                [glyphView.leftAnchor constraintEqualToAnchor:blank.leftAnchor constant:20.5].active = YES;
                [glyphView.centerYAnchor constraintEqualToAnchor:blank.centerYAnchor].active = YES;
                [glyphView.widthAnchor constraintEqualToConstant:glyphSize].active = YES;
                [glyphView.heightAnchor constraintEqualToConstant:glyphSize].active = YES;

                //battery.frame = CGRectMake(self.superview.bounds.size.width - 16 - 49,35 + y,20,10);

                battery.translatesAutoresizingMaskIntoConstraints = NO;
                [battery.leftAnchor constraintEqualToAnchor:blank.rightAnchor constant:(- 49)].active = YES;
                [battery.centerYAnchor constraintEqualToAnchor:blank.centerYAnchor].active = YES;
                [battery.widthAnchor constraintEqualToConstant:20].active = YES;
                [battery.heightAnchor constraintEqualToConstant:10].active = YES;

            y+=bannerHeight + spacing;
            self.number +=1;
            //blank.alpha = 0.8;
        }
    }
    //[self.heightAnchor constraintEqualToConstant:(self.number * 85)].active = YES;
    self.isUpdating = NO;
    }
    });
}

+(KAIBattery *)sharedInstance {
    return instance;
}

@end