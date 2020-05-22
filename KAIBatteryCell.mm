#import "KAIBatteryCell.h"

NSMutableArray *deviceInstances = [[NSMutableArray alloc] init];

@implementation KAIBatteryCell

-(instancetype)initWithFrame:(CGRect)arg1 device:(BCBatteryDevice *)device {
    self = [super initWithFrame:arg1];
    if(self) {

        self.device = device;

        NSString *deviceName = MSHookIvar<NSString *>(device, "_name");
        double batteryPercentage = MSHookIvar<long long>(device, "_percentCharge");
        BOOL charging = MSHookIvar<long long>(device, "_charging");
        BOOL LPM = MSHookIvar<BOOL>(device, "_batterySaverModeActive");

        UIView *blank;
        if(bannerStyle==1) {
            if(kCFCoreFoundationVersionNumber > 1600) {
                blank = [[[objc_getClass("MTMaterialView") class] alloc] _initWithRecipe:1 configuration:1 initialWeighting:1 scaleAdjustment:nil];
            } else if(kCFCoreFoundationVersionNumber < 1600) {
                blank = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            }
        } else if(bannerStyle==2) {
            blank = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        } else if(bannerStyle==3) {
            blank = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        }
        blank.layer.masksToBounds = YES;
        blank.layer.continuousCorners = YES;
        blank.layer.cornerRadius = cornerRadius;

        NSString *labelText = [NSString stringWithFormat:@"%@", deviceName];

        self.label = [[UILabel alloc] init];
        if(!hideDeviceLabel) {
            [self.label setFont:[UIFont systemFontOfSize:16]];
        } else if(hideDeviceLabel) {
            [self.label setFont:[UIFont systemFontOfSize:0]];
        }
        [self.label setTextColor:[UIColor whiteColor]];
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        self.label.numberOfLines = 1;
        [self.label setText:labelText];

        self.battery = [[_UIBatteryView alloc] init];
        self.battery.chargePercent = (batteryPercentage*0.01);
        self.percentLabel = [[UILabel alloc] init];
            self.battery.showsPercentage = NO;
                if(hidePercent) {
                    [self.percentLabel setFont:[UIFont systemFontOfSize:0]];
                } else {
                    [self.percentLabel setFont:[UIFont systemFontOfSize:14]];
                }
                [self.percentLabel setTextColor:[UIColor whiteColor]];
                self.percentLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [self.percentLabel setTextAlignment:NSTextAlignmentRight];
                self.percentLabel.numberOfLines = 1;
                [self.percentLabel setText:[NSString stringWithFormat:@"%ld%%", (long)((NSInteger) batteryPercentage)]];
        if(charging) self.battery.chargingState = 1;
        self.battery.showsInlineChargingIndicator = YES;
        if(LPM) self.battery.saverModeActive = YES;
        if(kCFCoreFoundationVersionNumber > 1600) {
            [self.battery setBodyColorAlpha:1.0];
            [self.battery setPinColorAlpha:1.0];
        }

        UIImage *glyph = [device glyph];
        self.glyphView = [[UIImageView alloc] init];
            self.glyphView.contentMode = UIViewContentModeScaleAspectFit;
            [self.glyphView setImage:glyph];

        [self addSubview:blank];
        [self addSubview:self.percentLabel];
        [self addSubview:self.label];
        [self addSubview:self.battery];
        [self addSubview:self.glyphView];

        blank.translatesAutoresizingMaskIntoConstraints = NO;
        if(bannerAlign==2) { //center
            [blank.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:horizontalOffset].active = YES;
        } else if(bannerAlign==1) { //left
            [blank.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:horizontalOffset].active = YES;
        } else if(bannerAlign==3) { //right
            [blank.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:horizontalOffset].active = YES;
        }
        [blank.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [blank.widthAnchor constraintEqualToConstant:((self.frame.size.width) + bannerWidthFactor)].active = YES;
        [blank.heightAnchor constraintEqualToConstant:bannerHeight].active = YES;

        self.percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.percentLabel.leftAnchor constraintEqualToAnchor:blank.rightAnchor constant:(- 96)].active = YES;
        [self.percentLabel.centerYAnchor constraintEqualToAnchor:blank.centerYAnchor].active = YES;
        [self.percentLabel.widthAnchor constraintEqualToConstant:37].active = YES;
        [self.percentLabel.heightAnchor constraintEqualToConstant:12].active = YES;

        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.label.leftAnchor constraintEqualToAnchor:self.glyphView.rightAnchor constant:4.5].active = YES;
        [self.label.centerYAnchor constraintEqualToAnchor:blank.centerYAnchor].active = YES;
        [self.label.rightAnchor constraintEqualToAnchor:self.percentLabel.leftAnchor constant:-4.5].active = YES;
        [self.label.heightAnchor constraintEqualToConstant:25].active = YES;

        self.glyphView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.glyphView.leftAnchor constraintEqualToAnchor:blank.leftAnchor constant:20.5].active = YES;
        [self.glyphView.centerYAnchor constraintEqualToAnchor:blank.centerYAnchor].active = YES;
        [self.glyphView.widthAnchor constraintEqualToConstant:glyphSize].active = YES;
        [self.glyphView.heightAnchor constraintEqualToConstant:glyphSize].active = YES;

        self.battery.translatesAutoresizingMaskIntoConstraints = NO;
        [self.battery.leftAnchor constraintEqualToAnchor:blank.rightAnchor constant:(- 49)].active = YES;
        [self.battery.centerYAnchor constraintEqualToAnchor:blank.centerYAnchor].active = YES;
        [self.battery.widthAnchor constraintEqualToConstant:20].active = YES;
        [self.battery.heightAnchor constraintEqualToConstant:10].active = YES;

        [deviceInstances addObject:self];
    }

    return self;
}

-(void)updateInfo {
    //NSLog(@"kai: updating cell info");

    NSString *deviceName = MSHookIvar<NSString *>(self.device, "_name");
    double batteryPercentage = MSHookIvar<long long>(self.device, "_percentCharge");
    BOOL charging = MSHookIvar<long long>(self.device, "_charging");
    BOOL LPM = MSHookIvar<BOOL>(self.device, "_batterySaverModeActive");

    self.label.text = [NSString stringWithFormat:@"%@", deviceName];
    [self.percentLabel setText:[NSString stringWithFormat:@"%ld%%", (long)((NSInteger) batteryPercentage)]];
    self.battery.chargePercent = (batteryPercentage*0.01);
    if(charging) { self.battery.chargingState = 1; } else { self.battery.chargingState = 0; }
    self.battery.showsInlineChargingIndicator = YES;
    if(LPM) { self.battery.saverModeActive = YES; } else { self.battery.saverModeActive = NO; }
    if(kCFCoreFoundationVersionNumber > 1600) {
        [self.battery setBodyColorAlpha:1.0];
        [self.battery setPinColorAlpha:1.0];
    }
    [self.percentLabel setText:[NSString stringWithFormat:@"%ld%%", (long)((NSInteger) batteryPercentage)]];
    self.battery.chargePercent = (batteryPercentage*0.01);

    [self.glyphView setImage:[self.device glyph]];

}

+(instancetype)cellForDeviceIfExists:(BCBatteryDevice *)device frameToCreateNew:(CGRect)arg2 {
    KAIBatteryCell *foundCell;

    //NSString *deviceName = MSHookIvar<NSString *>(device, "_name");

    for(KAIBatteryCell *cell in deviceInstances) {
        if(cell.device == device || [cell.device.identifier isEqualToString:device.identifier]) {
            foundCell = cell;
            break;
        }
    }

    if(foundCell == nil) {
        foundCell = [[KAIBatteryCell alloc] initWithFrame:arg2 device:device];
    }

    return foundCell;
    //return deviceInstances;
}

+(id)array {
    return deviceInstances;
}

@end