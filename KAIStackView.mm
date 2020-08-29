
@implementation KAIStackView

- (id)initWithFrame:(CGRect)arg1 {
    self = [super initWithFrame:arg1];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return self;
}

- (void)addArrangedSubview:(UIView *)view {
    [super addArrangedSubview:view];
    [[KAIBatteryPlatter sharedInstance] setContentSize:self.frame.size];

	if (textColor == 0 && [view respondsToSelector:@selector(updateInfo)]) {
	    KAIBatteryCell *cell = (KAIBatteryCell *)view;
		if (@available(iOS 12.0, *)) {
			if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
			    [cell.label setTextColor:[UIColor whiteColor]];
			    [cell.percentLabel setTextColor:[UIColor whiteColor]];
			} else if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
			    [cell.label setTextColor:[UIColor blackColor]];
			    [cell.percentLabel setTextColor:[UIColor blackColor]];
		    }
	    }
    }

    [[KAIBatteryPlatter sharedInstance] performSelector:@selector(resetOffset) withObject:[KAIBatteryPlatter sharedInstance] afterDelay:0.2];
}

- (void)removeArrangedSubview:(UIView *)subview {
    [super removeArrangedSubview:subview];
    [[KAIBatteryPlatter sharedInstance] performSelector:@selector(resetOffset) withObject:[KAIBatteryPlatter sharedInstance] afterDelay:0.2];
}

@end