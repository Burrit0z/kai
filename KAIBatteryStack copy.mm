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
        self.spacing = spacing;
        self.alignment = 0;
        [self updateBattery];
        self.clipsToBounds = YES;
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
    float y = 0;
    BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
            NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");
            if([devices count]!=0) {
                //NSLog(@"kai: info is good, will proceed");

            float ytwo = 0;

            for(KAIBatteryStackCell *cell in self.subviews) {
                if([cell respondsToSelector:@selector(updateInfo)] && ![devices containsObject:cell.device]) { //to confirm is a cell and battery device does not exist
                    //dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.2 animations:^{
                            cell.alpha = 0;
                        } completion:^(BOOL finished){
                            [cell removeFromSuperview];
                        }];
                    //});
                } else if([cell respondsToSelector:@selector(updateInfo)]) {
                        cell.frame = CGRectMake(0, y, self.frame.size.width, bannerHeight);
                        [cell updateInfo];
                        ytwo+= bannerHeight + spacing;
                }
            }


            for (BCBatteryDevice *device in devices) {
                NSString *deviceName = MSHookIvar<NSString *>(device, "_name");
                //double batteryPercentage = MSHookIvar<long long>(device, "_percentCharge");
                BOOL charging = MSHookIvar<long long>(device, "_charging");
                //BOOL LPM = MSHookIvar<BOOL>(device, "_batterySaverModeActive");

                BOOL shouldAdd = NO;

                if(showAll) {
                    shouldAdd = YES;
                    //NSLog(@"Kai: SHOULD ADD");
                } else if(!showAll && charging) {
                    shouldAdd = YES;
                    //NSLog(@"Kai: SHOULD ADD");
                }

                KAIBatteryStackCell *cell = [KAIBatteryStackCell cellForDeviceIfExists:device frameToCreateNew:CGRectMake(0, y, self.frame.size.width, bannerHeight)];
                cell.frame = CGRectMake(0, y, self.frame.size.width, bannerHeight);

                if(cell) {
                    cell.device = device;
                    //cell.frame = cell.frame = CGRectMake(0, y, self.frame.size.width, bannerHeight); //bro im like creating my own stack view
                    //[cell updateInfo];
                }

                if(shouldAdd && [deviceName length]!=0) {
                    if(![self.subviews containsObject:cell]) {
                        cell.frame = CGRectMake(0, y, self.frame.size.width, bannerHeight);
                        cell.alpha = 0;
                        [self addSubview:cell];
                        [UIView animateWithDuration:0.3 animations:^{
                            cell.alpha = 1;
                        }];
                    }
                    y+=bannerHeight + spacing;

                } else if(!shouldAdd) {
                    //dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.2 animations:^{
                            cell.alpha = 0;
                        } completion:^(BOOL finished){
                            [cell removeFromSuperview];
                        }];
                    //});
                }
            }
            //[self.heightAnchor constraintEqualToConstant:(self.number * 85)].active = YES;
            self.number = [self.subviews count];
            //[(CSAdjunctListView *)self.superview.superview KaiUpdate];
            }
            self.isUpdating = NO;
            //NSLog(@"kai: finished update");
            //[(CSAdjunctListView *)self.superview.superview KaiUpdate];
            [(CSAdjunctListView *)self.superview.superview performSelector:@selector(KaiUpdate) withObject:(CSAdjunctListView *)self.superview.superview afterDelay:0.2];
        }
    });
}

-(void)removeAllAndRefresh {
    for( UIView *view in self.subviews ) {
        @try {
            [view removeFromSuperview];
        } @catch (NSException *exception) {
            //Panik
        }
    }
    [KAIBatteryStackCell resetArray];

    //self.displayingDevices = [[NSMutableArray alloc] init];

    //addedCells = nil;
    [self updateBattery];
}

+(KAIBatteryStack *)sharedInstance {
    return instance;
}

@end