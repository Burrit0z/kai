
KAIBatteryPlatter *instance;
NSTimer *queueTimer = nil;

@implementation KAIBatteryPlatter

-(instancetype)initWithFrame:(CGRect)arg1 {
    self = [super initWithFrame:arg1];
    instance = self;
    if (self) {
        self.stack = [[KAIStackView alloc] init];
        self.stack.axis = kaiAlign==0 ? 1 : 0;
        self.stack.distribution = 0;
        self.stack.spacing = kaiAlign==0 ? 0 : spacingHorizontal;
        self.stack.alignment = 0;
        self.oldCountOfDevices = -100;
        self.queued = NO;

        [self setMinimumZoomScale:1];
        [self setMaximumZoomScale:1];
        [self addSubview:self.stack];
        [self setContentSize:self.stack.frame.size];
        [self setContentOffset:CGPointMake(0,0)];
        //[self setDelegate:self];

        [self updateBattery];
    }
    return self;
}

long long batteryPercentage;
long long lastPercentage;

-(void)updateBattery {
    if(!self.stack.widthAnchor) {
        [self.stack.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
        NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");
    
    if(self.oldCountOfDevices == -100) {
        self.oldCountOfDevices = [devices count] + 1;
    }
    for(KAIBatteryCell *cell in self.stack.subviews) {
        [cell updateInfo];
    }

    if(!self.isUpdating && self.oldCountOfDevices != 0 && ([devices count] + 1 == self.oldCountOfDevices || [devices count] - 1 == self.oldCountOfDevices || [devices count] == self.oldCountOfDevices)) {
    //if(!self.isUpdating) {

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

            if(![self.stack.subviews containsObject:cell] && shouldAdd && [devices containsObject:device]) {
                //[cell setFrame:CGRectMake(0,0,self.frame.size.width, bannerHeight)];
                cell.alpha = 0;
                [self.stack addSubview:cell];
                [self.stack addArrangedSubview:cell];
                [UIView animateWithDuration:0.3 animations:^{
                    cell.alpha = 1;
                }];
            } else if([self.stack.subviews containsObject:cell] && !shouldAdd){
                [UIView animateWithDuration:0.3 animations:^{
                    cell.alpha = 0;
                } completion:^(BOOL finished) {
                    [cell removeFromSuperview];
                    [self.stack removeArrangedSubview:cell];
                    cell.alpha = 1;
                }];
            }

        }

        for(KAIBatteryCell *cell in self.stack.subviews) {
            if(![devices containsObject:cell.device]) {
                [UIView animateWithDuration:0.3 animations:^{
                    cell.alpha = 0;
                } completion:^(BOOL finished) {
                    [cell removeFromSuperview];
                    [self.stack removeArrangedSubview:cell];
                    cell.alpha = 1;
                }];
            }
        }

        queueTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dispatchQueue) userInfo:nil repeats:NO];
        //self.isUpdating = NO;

        } else if(self.isUpdating) {
            self.queued = YES;
        }

        self.oldCountOfDevices = [devices count];

        self.number = [self.stack.subviews count];

    if([self.superview.superview.superview respondsToSelector:@selector(fixComplicationsViewFrame)]) {
        [(NCNotificationListView *)(self.superview.superview.superview) fixComplicationsViewFrame];
    }
    });

}

-(void)setContentOffset:(CGPoint)arg1 {
    [self setContentSize:self.stack.frame.size];
    [super setContentOffset:CGPointMake(arg1.x, 0)];
}

-(void)setNumber:(NSInteger)arg1 {
    _number = arg1;
    [self calculateHeight];
}

-(void)addSubview:(UIView *)view {
    [super addSubview:view];
    self.number = [self.stack.subviews count];
    if([self.superview.superview.superview respondsToSelector:@selector(fixComplicationsViewFrame)]) {
        [(NCNotificationListView *)(self.superview.superview.superview) fixComplicationsViewFrame];
    }

    if(textColor==0 && [view respondsToSelector:@selector(updateInfo)]) {
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

    [self setContentSize:self.stack.frame.size];
}

-(void)layoutSubviews {
    if([self.superview.superview.superview respondsToSelector:@selector(fixComplicationsViewFrame)]) {
        [(NCNotificationListView *)(self.superview.superview.superview) fixComplicationsViewFrame];
    }

}

-(void)calculateHeight {
    [UIView animateWithDuration:0.3 animations:^{

		if(!self.heightConstraint) {

			self.heightConstraint = [self.heightAnchor constraintEqualToConstant:(self.number * (bannerHeight + spacing))];
            self.stack.heightConstraint = [self.heightAnchor constraintEqualToConstant:(self.number * (bannerHeight + spacing))];
			self.heightConstraint.active = YES;
            self.stack.heightConstraint.active = YES;
            [self setContentSize:self.stack.frame.size];

		} else {
            int height = (self.number * (bannerHeight + spacing));
            if(kaiAlign==0) {
                height = (self.number * (bannerHeight + spacing));
            } else {
                height = bannerHeight + spacing;
            }

            if([self.superview.subviews count]>1) {
                height = height - spacing;
            }
			self.heightConstraint.constant = height;
            self.stack.heightConstraint.constant = height;

			UIStackView *s = (UIStackView *)(self.superview);
			s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, (s.frame.size.height - 1));
			//literally does nothing but makes the stack view lay itself out (doesnt adjust frame because translatesAutoreszingMaskIntoConstraints = NO on stack views)
		}

        }];

        if(self.number==0) {
            [(UIStackView *)(self.superview) removeArrangedSubview:self];
        } else if(self.number!=0 && !self.superview) {
            [[[[objc_getClass("CSAdjunctListView") class] sharedListViewForKai] stackView] addArrangedSubview:self];
            [self performSelector:@selector(calculateHeight) withObject:self afterDelay:0.1];
        }
}

-(void)refreshForPrefs {
    self.stack.spacing = kaiAlign==0 ? 0 : spacingHorizontal;
    [self setContentSize:self.stack.frame.size];
    for( UIView *view in self.stack.subviews ) {
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
    //self.spacing = spacing;
    [self updateBattery];
}

-(void)dispatchQueue {
    self.isUpdating = NO;
    if(self.queued) {
        [self updateBattery];
        if([self.superview.superview.superview respondsToSelector:@selector(fixComplicationsViewFrame)]) {
        [(NCNotificationListView *)(self.superview.superview.superview) fixComplicationsViewFrame];
        }
        self.queued = NO;
    }
    [queueTimer invalidate];
    queueTimer = nil;
}

+(KAIBatteryPlatter *)sharedInstance {
    return instance;
}

@end