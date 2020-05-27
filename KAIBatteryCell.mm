#import "KAIBatteryCell.h"

@implementation KAIBatteryCell

-(instancetype)initWithFrame:(CGRect)arg1 device:(BCBatteryDevice *)device {
    self = [super initWithFrame:arg1];
    if(self && device!=nil) {

        self.device = device;

        NSString *deviceName = device.name;
        double batteryPercentage = device.percentCharge;
        BOOL charging = MSHookIvar<long long>(device, "_charging");
        BOOL LPM = MSHookIvar<BOOL>(device, "_batterySaverModeActive");

        UIView *blur;
        UIView *blurPlatter = [[UIView alloc] init];
        if(bannerStyle==1) {
            if(kCFCoreFoundationVersionNumber > 1600) {
                blur = [[[objc_getClass("MTMaterialView") class] alloc] _initWithRecipe:1 configuration:1 initialWeighting:1 scaleAdjustment:nil];
            } else if(kCFCoreFoundationVersionNumber < 1600) {
                blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            }
        } else if(bannerStyle==2) {
            blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        } else if(bannerStyle==3) {
            blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        }
        blur.layer.masksToBounds = YES;
        blur.layer.continuousCorners = YES;
        blur.layer.cornerRadius = cornerRadius;
        blurPlatter.alpha = bannerAlpha;

        NSString *labelText = [NSString stringWithFormat:@"%@", deviceName];

        self.label = [[UILabel alloc] init];
        if(!hideDeviceLabel) {
            [self.label setFont:[UIFont systemFontOfSize:16]];
        } else if(hideDeviceLabel) {
            [self.label setFont:[UIFont systemFontOfSize:0]];
        }
        if(textColor==1) {
            [self.label setTextColor:[UIColor whiteColor]];
        } else {
            [self.label setTextColor:[UIColor blackColor]];
        }
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
                if(textColor==1) {
                    [self.percentLabel setTextColor:[UIColor whiteColor]];
                } else {
                    [self.percentLabel setTextColor:[UIColor blackColor]];
                }
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

        [self addSubview:blurPlatter];
        [blurPlatter addSubview:blur];
        [self addSubview:self.percentLabel];
        [self addSubview:self.label];
        [self addSubview:self.battery];
        [self addSubview:self.glyphView];

        blurPlatter.translatesAutoresizingMaskIntoConstraints = NO;
        if(bannerAlign==2) { //center
            [blurPlatter.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:horizontalOffset].active = YES;
        } else if(bannerAlign==1) { //left
            [blurPlatter.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:horizontalOffset].active = YES;
        } else if(bannerAlign==3) { //right
            [blurPlatter.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:horizontalOffset].active = YES;
        }
        [blurPlatter.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [blurPlatter.widthAnchor constraintEqualToConstant:((self.frame.size.width) + bannerWidthFactor)].active = YES;
        [blurPlatter.heightAnchor constraintEqualToConstant:bannerHeight].active = YES;

        blur.translatesAutoresizingMaskIntoConstraints = NO;
        [blur.centerXAnchor constraintEqualToAnchor:blurPlatter.centerXAnchor].active = YES;
        [blur.topAnchor constraintEqualToAnchor:blurPlatter.topAnchor].active = YES;
        [blur.widthAnchor constraintEqualToAnchor:blurPlatter.widthAnchor].active = YES;
        [blur.heightAnchor constraintEqualToAnchor:blurPlatter.heightAnchor].active = YES;

        self.percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.percentLabel.leftAnchor constraintEqualToAnchor:blurPlatter.rightAnchor constant:(- 96)].active = YES;
        [self.percentLabel.centerYAnchor constraintEqualToAnchor:blurPlatter.centerYAnchor].active = YES;
        [self.percentLabel.widthAnchor constraintEqualToConstant:37].active = YES;
        [self.percentLabel.heightAnchor constraintEqualToConstant:12].active = YES;

        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.label.leftAnchor constraintEqualToAnchor:self.glyphView.rightAnchor constant:4.5].active = YES;
        [self.label.centerYAnchor constraintEqualToAnchor:blurPlatter.centerYAnchor].active = YES;
        [self.label.rightAnchor constraintEqualToAnchor:self.percentLabel.leftAnchor constant:-4.5].active = YES;
        [self.label.heightAnchor constraintEqualToConstant:25].active = YES;

        self.glyphView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.glyphView.leftAnchor constraintEqualToAnchor:blurPlatter.leftAnchor constant:20.5].active = YES;
        [self.glyphView.centerYAnchor constraintEqualToAnchor:blurPlatter.centerYAnchor].active = YES;
        [self.glyphView.widthAnchor constraintEqualToConstant:glyphSize].active = YES;
        [self.glyphView.heightAnchor constraintEqualToConstant:glyphSize].active = YES;

        self.battery.translatesAutoresizingMaskIntoConstraints = NO;
        [self.battery.leftAnchor constraintEqualToAnchor:blurPlatter.rightAnchor constant:(- 49)].active = YES;
        [self.battery.centerYAnchor constraintEqualToAnchor:blurPlatter.centerYAnchor].active = YES;
        [self.battery.widthAnchor constraintEqualToConstant:20].active = YES;
        [self.battery.heightAnchor constraintEqualToConstant:10].active = YES;

    }

    return self;
}

-(void)traitCollectionDidChange:(id)arg1 {
    [super traitCollectionDidChange:arg1];
    if(textColor==0) {
        if(@available(iOS 12.0, *)) {
			if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                [self.label setTextColor:[UIColor whiteColor]];
                [self.percentLabel setTextColor:[UIColor whiteColor]];
            } else if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                [self.label setTextColor:[UIColor blackColor]];
                [self.percentLabel setTextColor:[UIColor blackColor]];   
            }
        }
    }
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
    [self.heightAnchor constraintEqualToConstant:(bannerHeight + spacing)].active = YES;

    /*if(!self.height) {
                
        self.height.active = NO;
        self.height = [self.heightAnchor constraintEqualToConstant:(bannerHeight + spacing)];
        self.height.active = YES;

    }*/ //else {
        //int height = (bannerHeight + spacing);
        //self.height.constant = height;
    //}

    if(!self.width) {
        
        self.width.active = NO;
        self.width = [self.widthAnchor constraintEqualToConstant:(self.frame.size.width)];
        self.width.active = YES;

    } //else {
        //int width = self.frame.size.width;
        //self.width.constant = width;
    //}

}

@end