#import "KAIClassHeaders.h"

@implementation KAIBatteryCell

- (instancetype)initWithFrame:(CGRect)arg1 device:(BCBatteryDevice *)device {
    self = [super initWithFrame:arg1];
	if (self && device != nil) {
	    self.device = device;

	    NSString *deviceName = device.name;
	    double batteryPercentage = device.percentCharge;
	    BOOL charging = [device isCharging];
	    BOOL LPM = [device isBatterySaverModeActive];

	    UIView *blur;
	    UIView *blurPlatter = [[UIView alloc] init];
		if (bannerStyle == 1) {
			if (kCFCoreFoundationVersionNumber > 1600) {
			    blur = [[[objc_getClass("MTMaterialView") class] alloc] _initWithRecipe:1 configuration:1 initialWeighting:1 scaleAdjustment:nil];
			} else if (kCFCoreFoundationVersionNumber < 1600) {
			    blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
		    }
		} else if (bannerStyle == 2) {
		    blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
		} else if (bannerStyle == 3) {
		    blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
	    }
	    blur.layer.masksToBounds = YES;
	    blur.layer.continuousCorners = YES;
	    blur.layer.cornerRadius = cornerRadius;
	    blurPlatter.alpha = bannerAlpha;

	    NSString *labelText = [NSString stringWithFormat:@"%@", deviceName];

	    self.label = [[UILabel alloc] init];
		if (!hideDeviceLabel) {
		    [self.label setFont:[UIFont systemFontOfSize:16]];
		} else if (hideDeviceLabel) {
		    [self.label setFont:[UIFont systemFontOfSize:0]];
	    }
		if (textColor == 1) {
		    [self.label setTextColor:[UIColor whiteColor]];
		} else {
		    [self.label setTextColor:[UIColor blackColor]];
		}
	    self.label.lineBreakMode = NSLineBreakByWordWrapping;
	    self.label.numberOfLines = 1;
	    [self.label setText:labelText];

	    self.battery = [[_UIBatteryView alloc] init];
	    self.battery.chargePercent = (batteryPercentage * 0.01);
	    self.percentLabel = [[UILabel alloc] init];
	    self.battery.showsPercentage = NO;
		if (hidePercent) {
		    [self.percentLabel setFont:[UIFont systemFontOfSize:0]];
		} else {
		    [self.percentLabel setFont:[UIFont systemFontOfSize:14]];
		}
		if (textColor == 1) {
		    [self.percentLabel setTextColor:[UIColor whiteColor]];
		} else {
		    [self.percentLabel setTextColor:[UIColor blackColor]];
		}
	    self.percentLabel.lineBreakMode = NSLineBreakByWordWrapping;
	    [self.percentLabel setTextAlignment:NSTextAlignmentRight];
	    self.percentLabel.numberOfLines = 1;
	    [self.percentLabel setText:[NSString stringWithFormat:@"%ld%%", (long)((NSInteger)batteryPercentage)]];
	    if (charging)
		self.battery.chargingState = 1;
	    self.battery.showsInlineChargingIndicator = YES;
	    if (LPM)
		self.battery.saverModeActive = YES;
		if (kCFCoreFoundationVersionNumber > 1600) {
		    [self.battery setBodyColorAlpha:1.0];
		    [self.battery setPinColorAlpha:1.0];
	    }

	    UIImage *glyph = ios13 ? [device glyph] : [device batteryWidgetGlyph];
	    self.glyphView = [[UIImageView alloc] init];
	    self.glyphView.contentMode = UIViewContentModeScaleAspectFit;
	    [self.glyphView setImage:glyph];

	    [self addSubview:blurPlatter];
	    [blurPlatter addSubview:blur];
	    [self addSubview:self.percentLabel];
	    [self addSubview:self.label];
	    [self addSubview:self.battery];
	    [self addSubview:self.glyphView];

	    // Blur Platter
	    blurPlatter.translatesAutoresizingMaskIntoConstraints = NO;
		if (bannerAlign == 2) { //center
		    [blurPlatter.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
		} else if (bannerAlign == 1) { //left
		    [blurPlatter.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
		} else if (bannerAlign == 3) { //right
		    [blurPlatter.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
	    }
	    [NSLayoutConstraint activateConstraints:@[
		[blurPlatter.topAnchor constraintEqualToAnchor:self.topAnchor],
		[blurPlatter.widthAnchor constraintEqualToConstant:(([[[objc_getClass("CSAdjunctListView") class] sharedListViewForKai] stackView].frame.size.width - 16) + bannerWidthFactor)],
		[blurPlatter.heightAnchor constraintEqualToConstant:bannerHeight]
	    ]];

	    [self.widthAnchor constraintEqualToAnchor:blurPlatter.widthAnchor].active = YES;

	    // Blur
	    blur.translatesAutoresizingMaskIntoConstraints = NO;
	    [NSLayoutConstraint activateConstraints:@[
		[blur.centerXAnchor constraintEqualToAnchor:blurPlatter.centerXAnchor],
		[blur.topAnchor constraintEqualToAnchor:blurPlatter.topAnchor],
		[blur.widthAnchor constraintEqualToAnchor:blurPlatter.widthAnchor],
		[blur.heightAnchor constraintEqualToAnchor:blurPlatter.heightAnchor]
	    ]];

	    // Percent label
	    self.percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
	    [NSLayoutConstraint activateConstraints:@[
		[self.percentLabel.centerYAnchor constraintEqualToAnchor:blurPlatter.centerYAnchor],
		[self.percentLabel.widthAnchor constraintEqualToConstant:36],
		[self.percentLabel.heightAnchor constraintEqualToConstant:12]
	    ]];

	    // Label
	    self.label.translatesAutoresizingMaskIntoConstraints = NO;
	    [NSLayoutConstraint activateConstraints:@[
		[self.label.leftAnchor constraintEqualToAnchor:self.glyphView.rightAnchor
						      constant:4.5],
		[self.label.centerYAnchor constraintEqualToAnchor:blurPlatter.centerYAnchor],
		[self.label.heightAnchor constraintEqualToConstant:25]
	    ]];
		if (!hidePercent) {
		    [self.label.rightAnchor constraintEqualToAnchor:self.percentLabel.leftAnchor constant:-4.5].active = YES;
		} else {
		    [self.label.rightAnchor constraintEqualToAnchor:self.label.leftAnchor].active = YES;
		}

	    // Glyph View
	    self.glyphView.translatesAutoresizingMaskIntoConstraints = NO;
	    [NSLayoutConstraint activateConstraints:@[
		[self.glyphView.leftAnchor constraintEqualToAnchor:blurPlatter.leftAnchor
							  constant:20.5],
		[self.glyphView.centerYAnchor constraintEqualToAnchor:blurPlatter.centerYAnchor],
		[self.glyphView.widthAnchor constraintEqualToConstant:glyphSize],
		[self.glyphView.heightAnchor constraintEqualToConstant:glyphSize]
	    ]];

	    // Battery
	    self.battery.translatesAutoresizingMaskIntoConstraints = NO;
		if (!hideBatteryIcon) {
		    [self.battery.widthAnchor constraintEqualToConstant:20].active = YES;
		} else {
		    [self.battery.widthAnchor constraintEqualToConstant:0].active = YES;
		    self.battery.alpha = 0;
		}
	    [NSLayoutConstraint activateConstraints:@[
		[self.battery.centerYAnchor constraintEqualToAnchor:blurPlatter.centerYAnchor],
		[self.battery.rightAnchor constraintEqualToAnchor:blurPlatter.rightAnchor
							 constant:-20.5],
		[self.battery.heightAnchor constraintEqualToConstant:10]
	    ]];

		if (!hideDeviceLabel) {
		    [self.percentLabel.rightAnchor constraintEqualToAnchor:self.battery.leftAnchor constant:-4.5].active = YES;
		} else if (hideDeviceLabel) {
		    [self.percentLabel.centerXAnchor constraintEqualToAnchor:blurPlatter.centerXAnchor].active = YES;
	    }

		if (hidePercent) {
		    [self.label.rightAnchor constraintEqualToAnchor:self.battery.leftAnchor constant:-4.5].active = YES;
	    }

	    [self.heightAnchor constraintEqualToConstant:(bannerHeight + spacing)];
    }

    return self;
}

- (void)traitCollectionDidChange:(id)arg1 {
    [super traitCollectionDidChange:arg1];
	if (textColor == 0) {
		if (@available(iOS 12.0, *)) {
			if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
			    [self.label setTextColor:[UIColor whiteColor]];
			    [self.percentLabel setTextColor:[UIColor whiteColor]];
			} else if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
			    [self.label setTextColor:[UIColor blackColor]];
			    [self.percentLabel setTextColor:[UIColor blackColor]];
		    }
	    }
    }
}

- (void)updateInfo {
	if (self.device != nil) {
	    NSString *deviceName = [self.device name];
	    double batteryPercentage = [self.device percentCharge];
	    BOOL charging = [self.device isCharging];
	    BOOL LPM = [self.device isBatterySaverModeActive];

	    self.label.text = [NSString stringWithFormat:@"%@", deviceName];
	    [self.percentLabel setText:[NSString stringWithFormat:@"%ld%%", (long)((NSInteger)batteryPercentage)]];
	    self.battery.chargePercent = (batteryPercentage * 0.01);
		if (charging) {
		    self.battery.chargingState = 1;
		} else {
		    self.battery.chargingState = 0;
		}
	    self.battery.showsInlineChargingIndicator = YES;
		if (LPM) {
		    self.battery.saverModeActive = YES;
		} else {
		    self.battery.saverModeActive = NO;
		}
		if (kCFCoreFoundationVersionNumber > 1600) {
		    [self.battery setBodyColorAlpha:1.0];
		    [self.battery setPinColorAlpha:1.0];
	    }
	    [self.percentLabel setText:[NSString stringWithFormat:@"%ld%%", (long)((NSInteger)batteryPercentage)]];
	    self.battery.chargePercent = (batteryPercentage * 0.01);

	    [self.glyphView setImage:ios13 ? [self.device glyph] : [self.device batteryWidgetGlyph]];
	} else {
	}
}

- (void)removeFromSuperview {
    self.device.kaiCell = nil;
    [super removeFromSuperview];
}

@end