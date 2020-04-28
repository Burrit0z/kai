#import "KAIBattery.h"

KAIBattery *instance;
@implementation KAIBattery

-(instancetype)initWithFrame:(CGRect)arg1 {
    self = [super initWithFrame:arg1];
    instance = self;
    if (self) {
        /*self.batteryLabel = [[UILabel alloc]initWithFrame:CGRectMake(25,-10,220,120)];
        [self.batteryLabel setFont:[UIFont systemFontOfSize:13]];
        [self.batteryLabel setTextColor:[UIColor whiteColor]];
        self.batteryLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.batteryLabel.numberOfLines = 0;*/
        [self updateBattery];
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

                float y;
                if(charging) {

                    UIVisualEffectView *blank = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
                    blank.frame = CGRectMake(0, 0 + y, self.frame.size.width, 80);
                    blank.layer.masksToBounds = YES;
                    blank.layer.cornerRadius = 13;
                    blank.alpha = 0;
                    //[blank setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1]];

                NSString *labelText = [NSString stringWithFormat:@"%@", deviceName];

                UILabel *label = [[UILabel alloc] init];
                    [label setFont:[UIFont systemFontOfSize:16]];
                [label setTextColor:[UIColor whiteColor]];
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.numberOfLines = 0;
                label.alpha = 0;
                [label setText:labelText];

                _UIBatteryView *battery = [[_UIBatteryView alloc] init];
                battery.chargePercent = (batteryPercentage*0.01);
                UILabel *percentLabel = [[UILabel alloc] init];
                percentLabel.alpha = 0;
                battery.alpha = 0;
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
                glyphView.alpha = 0;
                    glyphView.contentMode = UIViewContentModeScaleAspectFit;
                    [glyphView setImage:glyph];

                label.frame = CGRectMake(57.5,27.5 + y,275,25);
                glyphView.frame = CGRectMake(12.5,18.5 + y,40,40);
                battery.frame = CGRectMake(310,35 + y,20,10);
                percentLabel.frame = CGRectMake(265,35 + y,36,12);

            y+=85;
            self.number +=1;

            [self addSubview:blank];
            [self addSubview:percentLabel];
            [self addSubview:label];
            [self addSubview:battery];
            [self addSubview:glyphView];
            blank.alpha = 0.8;
            percentLabel.alpha = 1;
            battery.alpha = 1;
            label.alpha = 1;
            glyphView.alpha = 1;
        }
    }
    self.isUpdating = NO;
    }
    });
}

+(KAIBattery *)sharedInstance {
    return instance;
}

@end