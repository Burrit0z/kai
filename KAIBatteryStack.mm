#import "KAIBatteryStack.h"

KAIBatteryStack *instance;
//NSMutableArray *showingCells = [[NSMutableArray alloc] init];

@implementation KAIBatteryStack

-(instancetype)init {
    self = [super init];
    instance = self;
    if (self) {
        self.displayingDevices = [[NSMutableArray alloc] init];
        self.axis = 1;
        self.distribution = 0;
        self.spacing = 0;
        self.alignment = 0;
        [self updateBattery];
        //self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
    }
    return self;
}

long long batteryPercentage;
long long lastPercentage;

-(void)updateBattery {
    self.spacing = spacing;
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"kai: battery platter called to update");
    if(!self.isUpdating) {
        //NSLog(@"kai: IS Updating");
    self.isUpdating = YES;
    //self.number = 0;
    //float y = 0;
    BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
        NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");

        //NSLog(@"kai: devices are %@", devices);
        
        for (BCBatteryDevice *device in devices) {
            KAIBatteryCell *cell = [device kaiCellForDevice];
            BOOL charging = MSHookIvar<long long>(device, "_charging");

            [cell updateInfo];
            BOOL shouldAdd = NO;

            if(showAll) {
                shouldAdd = YES;
            } else if(!showAll && charging) {
                shouldAdd = YES;
            }

            if(![self.subviews containsObject:cell] && shouldAdd && [devices containsObject:device]) {
                //[cell setFrame:CGRectMake(0,0,self.frame.size.width, bannerHeight)];
                cell.alpha = 0;
                [self addSubview:cell];
                [self addArrangedSubview:cell];
                [UIView animateWithDuration:0.3 animations:^{
                    cell.alpha = 1;
                }];
            } else if([self.subviews containsObject:cell] && !shouldAdd){
                [UIView animateWithDuration:0.3 animations:^{
                    cell.alpha = 0;
                } completion:^(BOOL finished) {
                    [cell removeFromSuperview];
                    [self removeArrangedSubview:cell];
                    cell.alpha = 1;
                }];
            }

        }
                                                                                                                                                                                              
        self.number = [self.subviews count];
        }
        self.isUpdating = NO;
        //NSLog(@"kai: finished update");
        //[(CSAdjunctListView *)self.superview.superview KaiUpdate];
        [(CSAdjunctListView *)self.superview.superview performSelector:@selector(KaiUpdate) withObject:(CSAdjunctListView *)self.superview.superview afterDelay:0.2];
    });
    self.number = [self.subviews count];
}

-(void)refreshForPrefs {
    for( UIView *view in self.subviews ) {
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

    [self updateBattery];
}

+(KAIBatteryStack *)sharedInstance {
    return instance;
}

@end