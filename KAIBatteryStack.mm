#import "KAIBatteryStack.h"

KAIBatteryStack *instance;
NSTimer *queueTimer = nil;
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
        self.oldCountOfDevices = -100;
        self.queued = NO;
        [self updateBattery];
        //self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
    }
    return self;
}

long long batteryPercentage;
long long lastPercentage;

-(void)updateBattery {
    dispatch_async(dispatch_get_main_queue(), ^{
        BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
        NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");
    
    if(self.oldCountOfDevices == -100) {
        self.oldCountOfDevices = [devices count] + 1;
    }
    self.oldCountOfDevices = [devices count];

    for (BCBatteryDevice *device in devices) {
        KAIBatteryCell *cell = [device kaiCellForDevice];

        [cell updateInfo];
    }

    if(!self.isUpdating && self.oldCountOfDevices != 0 && ([devices count] + 1 == self.oldCountOfDevices || [devices count] - 1 == self.oldCountOfDevices || [devices count] == self.oldCountOfDevices)) {

    self.isUpdating = YES;

        
        for (BCBatteryDevice *device in devices) {
            KAIBatteryCell *cell = [device kaiCellForDevice];
            BOOL charging = MSHookIvar<long long>(device, "_charging");
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

        queueTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dispatchQueue) userInfo:nil repeats:NO];

        } else if(self.isUpdating) {
            self.queued = YES;
        }
        
        self.number = [self.subviews count];
        [(CSAdjunctListView *)self.superview.superview KaiUpdate];

    });

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

-(void)dispatchQueue {
    self.isUpdating = NO;
    if(self.queued) {
        [self updateBattery];
        self.queued = NO;
    }
    [queueTimer invalidate];
    queueTimer = nil;
}

+(KAIBatteryStack *)sharedInstance {
    return instance;
}

@end