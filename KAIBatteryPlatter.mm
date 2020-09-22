
KAIBatteryPlatter *instance;
NSTimer *queueTimer = nil;
NSMutableArray *deviceNames = [[NSMutableArray alloc] init];
NSMutableArray *cellsForDeviceNames = [[NSMutableArray alloc] init];

@implementation KAIBatteryPlatter

- (instancetype)initWithFrame:(CGRect)arg1 {
    self = [super initWithFrame:arg1];
    instance = self;

	if (self) {
	    self.stackHolder = [[UIView alloc] initWithFrame:arg1];
	    self.stack = [[KAIStackView alloc] init];
	    self.stack.axis = kaiAlign == 0 ? 1 : 0;
	    self.stack.distribution = UIStackViewDistributionFillEqually;
	    self.stack.spacing = kaiAlign == 0 ? 0 : spacingHorizontal;
	    self.stack.alignment = 0;
	    self.oldCountOfDevices = -100;
	    self.queued = NO;
	    [self setShowsHorizontalScrollIndicator:NO];
	    [self setShowsVerticalScrollIndicator:NO];

	    [self setMinimumZoomScale:1];
	    [self setMaximumZoomScale:1];
	    [self addSubview:self.stackHolder];
	    [self.stackHolder addSubview:self.stack];
	    [self setContentSize:self.stack.frame.size];
	    [self resetOffset];

	    //Add noti observer
	    [[NSNotificationCenter defaultCenter] addObserver:self
						     selector:@selector(resetOffset)
							 name:@"KaiResetOffset"
						       object:nil];

	    self.stackHolder.translatesAutoresizingMaskIntoConstraints = NO;
	    [self.stackHolder.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
	    [self.stackHolder.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
	    [self.stackHolder.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;

		if (kaiAlign == 0) {
			if (bannerAlign == 2) { //center
			    self.subviewAligner = [self.stack.centerXAnchor constraintEqualToAnchor:self.stackHolder.centerXAnchor constant:horizontalOffset];
			} else if (bannerAlign == 1) { //left
			    self.subviewAligner = [self.stack.leftAnchor constraintEqualToAnchor:self.stackHolder.leftAnchor constant:horizontalOffset];
			} else if (bannerAlign == 3) { //right
			    self.subviewAligner = [self.stack.rightAnchor constraintEqualToAnchor:self.stackHolder.rightAnchor constant:horizontalOffset];
		    }

		    self.subviewAligner.active = YES;
	    }

	    [self updateBattery];
    }
    return self;
}

- (void)resetOffset {
	if (kaiAlign != 0 && reAlignSelf) {
	    [UIView animateWithDuration:0.2
			     animations:^{
			       if (bannerAlign == 1) { //left
				   [self setContentOffset:CGPointMake(0 + horizontalOffset, self.contentOffset.y)];

				   self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
			       } else if (bannerAlign == 2) { //center
				   [self setContentOffset:CGPointMake(((-1 * self.stackHolder.frame.size.width) / 2) + (self.stack.frame.size.width / 2) + horizontalOffset, self.contentOffset.y)];

				   CGFloat top = 0, left = 0;
				       if (self.contentSize.width < self.bounds.size.width) {
					   left = (self.bounds.size.width - self.contentSize.width) * 0.5f;
				   }
				       if (self.contentSize.height < self.bounds.size.height) {
					   top = (self.bounds.size.height - self.contentSize.height) * 0.5f;
				   }
				   self.contentInset = UIEdgeInsetsMake(top, left, top, left);

			       } else if (bannerAlign == 3) { //right
				   [self setContentOffset:CGPointMake((-1 * self.stackHolder.frame.size.width) + self.stack.frame.size.width + horizontalOffset, self.contentOffset.y)];

				   CGFloat top = 0, left = 0;
				       if (self.contentSize.width < self.bounds.size.width) {
					   left = (self.bounds.size.width - self.contentSize.width);
				   }
				       if (self.contentSize.height < self.bounds.size.height) {
					   top = (self.bounds.size.height - self.contentSize.height);
				   }
				   self.contentInset = UIEdgeInsetsMake(top, left, top, left);
			   }
			     }];
    }
}

- (void)setClipsToBounds:(BOOL)arg1 {
    [super setClipsToBounds:NO];
}

- (void)updateBattery {
    dispatch_async(dispatch_get_main_queue(), ^{
      BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
      NSArray *devices =  ios13 ? [bcb sortedDevices] : [bcb connectedDevices];

	  if (self.oldCountOfDevices == -100) {
	      self.oldCountOfDevices = [devices count] + 1;
      }
	  for (KAIBatteryCell *cell in self.stack.subviews) {
	      [cell updateInfo];
	  }

	  if (!self.isUpdating && self.oldCountOfDevices != 0 && ([devices count] + 1 == self.oldCountOfDevices || [devices count] - 1 == self.oldCountOfDevices || [devices count] == self.oldCountOfDevices)) {
	      //if(!self.isUpdating) {

	      self.isUpdating = YES;

	      NSMutableArray *cellsToAdd = [[NSMutableArray alloc] init];
	      NSMutableArray *cellsToRemove = [[NSMutableArray alloc] init];

		  for (BCBatteryDevice *device in devices) {
		      KAIBatteryCell *cell = [device kaiCellForDevice];
		      BOOL charging = [device isCharging];
		      BOOL internal = [device isInternal];
		      BOOL shouldAdd = NO;
		      BOOL fake = [device isFake];
		      NSString *deviceName = [device name];

			  if (!fake) {
				  if (showAll) {
				      shouldAdd = YES;
				  } else if (showAllMinusInternal && !internal) {
				      shouldAdd = YES;
				  } else if (!showAll && charging) {
				      shouldAdd = YES;
			      }
		      }

			  if (!showPhone && internal) {
			      shouldAdd = NO;
		      }

			  if (![self.stack.subviews containsObject:cell] && shouldAdd && [devices containsObject:device]) {
				  if (![deviceNames containsObject:deviceName]) {
				      [cellsToAdd addObject:cell];
				      [deviceNames addObject:deviceName];
				      [cellsForDeviceNames addObject:cell];
				  } else {
					  for (int i = 0; i < [deviceNames count]; i++) {
						  if ([[deviceNames objectAtIndex:i] isEqualToString:deviceName]) {
						      KAIBatteryCell *cell = [cellsForDeviceNames objectAtIndex:i];
						      cell.device = device;
						      if ([cellsToRemove containsObject:cell])
							  [cellsToRemove removeObject:cell];
						      [cell updateInfo];
					      }
					  }
				  }
			  } else if ([self.stack.subviews containsObject:cell] && !shouldAdd) {
			      [cellsToRemove addObject:cell];
			      // this is where i stupidly removed from deviceName names :kekw:
		      }
		  }

		  for (KAIBatteryCell *cell in cellsToAdd) {
		      if ([cellsToRemove containsObject:cell])
			  [cellsToRemove removeObject:cell];
			  if (![self.stack.subviews containsObject:cell] && [devices containsObject:cell.device]) {
			      // add cell
			      cell.alpha = 0;
			      [self.stack addSubview:cell];
			      [self.stack addArrangedSubview:cell];
			      [UIView animateWithDuration:0.3
					       animations:^{
						 cell.alpha = 1;
					       }];
		      }
		  }

		  for (KAIBatteryCell *cell in cellsToRemove) {
		      // remove cell
		      [UIView animateWithDuration:0.3
			  animations:^{
			    cell.alpha = 0;
			  }
			  completion:^(BOOL finished) {
			    [cell removeFromSuperview];
			    [self.stack removeArrangedSubview:cell];
			    cell.alpha = 1;
			  }];
		      NSString *deviceName = [cell.device name];
		      [deviceNames removeObject:deviceName];
		      [cellsForDeviceNames removeObject:cell];
		  }

		  for (KAIBatteryCell *cell in self.stack.subviews) {
			  if (![devices containsObject:cell.device] || cell.device == nil) { //not existing, remove
			      NSString *deviceName = cell.label.text;
			      [UIView animateWithDuration:0.3
				  animations:^{
				    cell.alpha = 0;
				  }
				  completion:^(BOOL finished) {
				    [cell removeFromSuperview];
				    [self.stack removeArrangedSubview:cell];
				    cell.alpha = 1;
				  }];
			      [deviceNames removeObject:deviceName];
			      [cellsForDeviceNames removeObject:cell];
		      }
		  }

	      queueTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dispatchQueue) userInfo:nil repeats:NO];
	      //self.isUpdating = NO;

	  } else if (self.isUpdating) {
	      self.queued = YES;
      }

      self.oldCountOfDevices = [devices count];

      [self calculateHeight];

	  if ([self.superview.superview.superview respondsToSelector:@selector(fixComplicationsViewFrame)]) {
	      [(NCNotificationListView *)(self.superview.superview.superview) fixComplicationsViewFrame];
      }

      [self setContentSize:self.stack.frame.size];
      [self performSelector:@selector(resetOffset) withObject:self afterDelay:0.2];
    });
}

- (void)setContentOffset:(CGPoint)arg1 {
    [self setContentSize:self.stack.frame.size]; //sometimes the view gets "stuck", this fixes it
    [super setContentOffset:CGPointMake(arg1.x, 0)];
}

- (void)calculateHeight {
    self.number = [self.stack.subviews count];

	if (self.number == 0) {
	    UIStackView *s = (UIStackView *)(self.superview);
	    s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, (s.frame.size.height - 1));
	    [s removeArrangedSubview:self];
	    [self removeFromSuperview];
	} else if (self.number != 0 && self.superview == nil && shouldBeAdded == YES) {
	    [[[[objc_getClass("CSAdjunctListView") class] sharedListViewForKai] stackView] addArrangedSubview:self];
	    //[self performSelector:@selector(calculateHeight) withObject:self afterDelay:0.1];
    }

    [UIView animateWithDuration:0.3
		     animations:^{
		       if (!self.heightConstraint) {
			   int height = (self.number * (bannerHeight + spacing));
			       if (kaiAlign != 0) {
				   height = bannerHeight + spacing;
			   }

			       if ([self.superview.subviews count] > 1) {
				   height = (height - spacing) + 1;
			   }

			   self.heightConstraint = [self.heightAnchor constraintEqualToConstant:height];
			   self.stack.heightConstraint = [self.stack.heightAnchor constraintEqualToConstant:height];
			   self.heightConstraint.active = YES;
			   self.stack.heightConstraint.active = YES;
			   [self setContentSize:self.stack.frame.size];
			   [self resetOffset];

		       } else {
			   int height = (self.number * (bannerHeight + spacing));
			   int extra = extraPaddingAfter ? spacing : 0;
			       if (kaiAlign == 0) {
				   //self.stack.widthConstraint.constant = bannerWidthFactor;
			       } else {
				   height = bannerHeight + spacing;
			       }

			   height = height + extra;

			       if ([self.superview.subviews count] > 1) {
				   height = (height - spacing + 1);
			   }

			   self.heightConstraint.constant = height;
			   self.stack.heightConstraint.constant = height - extra; //minus extra because it will stretch cell spacing otherwise

			   UIStackView *s = (UIStackView *)(self.superview);
			   s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, (s.frame.size.height - 1));
			   //literally does nothing but makes the stack view lay itself out (doesnt adjust frame because translatesAutoreszingMaskIntoConstraints = NO on stack views)
		       }

		   [self setContentSize:self.stack.frame.size];
		   [self resetOffset];
		     }];
}

- (void)removeFromSuperview {
    [self.superview setNeedsLayout];
    [super removeFromSuperview];
}

- (void)refreshForPrefs {
    self.stack.spacing = kaiAlign == 0 ? 0 : spacingHorizontal;
    [self setContentSize:self.stack.frame.size];
	for (UIView *view in self.stack.subviews) {
		@try {
		    [view removeFromSuperview];
		} @catch (NSException *exception) {
		    //Panik
	    }
	}

    BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
    NSArray *devices = ios13 ? [bcb sortedDevices] : [bcb connectedDevices];
	for (BCBatteryDevice *device in devices) {
	    [device resetKaiCellForNewPrefs];
	}

	if (kaiAlign == 0) {
	    self.subviewAligner.active = NO;
		if (bannerAlign == 2) { //center
		    self.subviewAligner = [self.stack.centerXAnchor constraintEqualToAnchor:self.stackHolder.centerXAnchor constant:horizontalOffset];
		} else if (bannerAlign == 1) { //left
		    self.subviewAligner = [self.stack.leftAnchor constraintEqualToAnchor:self.stackHolder.leftAnchor constant:horizontalOffset];
		} else if (bannerAlign == 3) { //right
		    self.subviewAligner = [self.stack.rightAnchor constraintEqualToAnchor:self.stackHolder.rightAnchor constant:horizontalOffset];
	    }

	    self.subviewAligner.active = YES;
    }

    [cellsForDeviceNames removeAllObjects];
    [deviceNames removeAllObjects];

    [self updateBattery];
}

- (void)dispatchQueue {
    self.isUpdating = NO;
	if (self.queued) {
	    [self updateBattery];
		if ([self.superview.superview.superview respondsToSelector:@selector(fixComplicationsViewFrame)]) {
		    [(NCNotificationListView *)(self.superview.superview.superview) fixComplicationsViewFrame];
	    }
	    self.queued = NO;
    }
    [queueTimer invalidate];
    queueTimer = nil;
}

+ (KAIBatteryPlatter *)sharedInstance {
    return instance;
}

//This is for compatibility (did i spell that right?)
//basically this fixes it crashing in landscape:

- (void)setSizeToMimic:(CGSize)arg1 {
}

@end