#import "KAIBattery.h"

@implementation KAIBattery

-(instancetype)initWithFrame:(CGRect)arg1 {
    self = [super initWithFrame:arg1];
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
    self.number = 0;
            NSArray* subViews = self.subviews;
            for( UIView *view in subViews ) {
                @try {
                    [view removeFromSuperview];
                } @catch (NSException *exception) {
                    //Panik
                }
            }
        BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
            NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");

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
                    blank.layer.cornerRadius = 18;
                    //[blank setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1]];
                    [self addSubview:blank];

                NSString *labelText = [NSString stringWithFormat:@"%@", deviceName];

                UILabel *label = [[UILabel alloc] init];
                    [label setFont:[UIFont systemFontOfSize:16]];
                [label setTextColor:[UIColor whiteColor]];
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.numberOfLines = 0;
                [label setText:labelText];

                [self addSubview:label];

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
                        [self addSubview:percentLabel];
                if(charging) battery.chargingState = 1;
                battery.showsInlineChargingIndicator = YES;
                if(LPM) battery.saverModeActive = YES;
                if(kCFCoreFoundationVersionNumber > 1600) {
                    [battery setBodyColorAlpha:1.0];
                    [battery setPinColorAlpha:1.0];
                }
                [self addSubview:battery];

                UIImage *glyph = [device glyph];
                UIImageView *glyphView = [[UIImageView alloc] init];
                    glyphView.contentMode = UIViewContentModeScaleAspectFit;
                    [glyphView setImage:glyph];
                    [self addSubview:glyphView];

                label.frame = CGRectMake(57.5,27.5 + y,275,25);
                glyphView.frame = CGRectMake(12.5,18.5 + y,40,40);
                battery.frame = CGRectMake(310,35 + y,20,10);
                percentLabel.frame = CGRectMake(265,35 + y,36,12);

            y+=90;
            self.number +=1;
        }
    }
}

@end