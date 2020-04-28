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
    NSArray* subViews = self.subviews;
    for( UIView *view in subViews ) {
        @try {
            [view removeFromSuperview];
        } @catch (NSException *exception) {
            //Panik
    }
    BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
        NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");

    for (BCBatteryDevice *device in devices) {
        NSString *deviceName = MSHookIvar<NSString *>(device, "_name");
        double batteryPercentage = MSHookIvar<long long>(device, "_percentCharge");
        BOOL charging = MSHookIvar<long long>(device, "_charging");
        BOOL LPM = MSHookIvar<BOOL>(device, "_batterySaverModeActive");

        NSString *labelText = [NSString stringWithFormat:@"%@", deviceName];

        UILabel *label = [[UILabel alloc] init];
        if([devices count]>=4) {
            [label setFont:[UIFont systemFontOfSize:19]];
        }
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

        label.frame = CGRectMake(57.5,27.5,275,25);
            glyphView.frame = CGRectMake(12.5,18.5,40,40);
            battery.frame = CGRectMake(310,35,20,10);
            percentLabel.frame = CGRectMake(265,35,36,12);
        }
    }
}

/*
label.frame = CGRectMake(57.5,27.5,275,25);
            glyphView.frame = CGRectMake(12.5,18.5,40,40);
            battery.frame = CGRectMake(310,35,20,10);
            percentLabel.frame = CGRectMake(265,35,36,12);*/

@end