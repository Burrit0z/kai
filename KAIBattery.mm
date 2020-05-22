#import "KAIBattery.h"

KAIBattery *instance;
//NSMutableArray *showingCells = [[NSMutableArray alloc] init];

@implementation KAIBattery

-(instancetype)init {
    self = [super init];
    instance = self;
    if (self) {
        self.displayingDevices = [[NSMutableArray alloc] init];
        [self updateBattery];
        self.userInteractionEnabled = NO;
    }
    return self;
}

long long batteryPercentage;
long long lastPercentage;

-(void)updateBattery {
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

            for(KAIBatteryCell *cell in self.subviews) {
                if([cell respondsToSelector:@selector(updateInfo)] && ![devices containsObject:cell.device]) { //to confirm is a cell and battery device does not exist
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell removeFromSuperview];
                    });
                } else if([cell respondsToSelector:@selector(updateInfo)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell updateInfo];
                    });
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

                KAIBatteryCell *cell = [KAIBatteryCell cellForDeviceIfExists:device frameToCreateNew:CGRectMake(0, y, self.frame.size.width, bannerHeight)];

                if(cell) {
                    cell.device = device;
                    cell.frame = cell.frame = CGRectMake(0, y, self.frame.size.width, bannerHeight); //bro im like creating my own stack view
                    //[cell updateInfo];
                }

                if(shouldAdd && [deviceName length]!=0) {
                    if(![self.subviews containsObject:cell]) {
                        cell.frame = CGRectMake(0, y, self.frame.size.width, bannerHeight);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self addSubview:cell];
                        });
                    }
                    y+=bannerHeight + spacing;

                } else if(!shouldAdd) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell removeFromSuperview];
                    });
                }
            }
            //[self.heightAnchor constraintEqualToConstant:(self.number * 85)].active = YES;
            self.number = [self.subviews count];
            //[(CSAdjunctListView *)self.superview.superview KaiUpdate];
            }
            self.isUpdating = NO;
            //NSLog(@"kai: finished update");
            [(CSAdjunctListView *)self.superview.superview KaiUpdate];
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
    [KAIBatteryCell resetArray];

    //self.displayingDevices = [[NSMutableArray alloc] init];

    //addedCells = nil;
    [self updateBattery];
}

+(KAIBattery *)sharedInstance {
    return instance;
}

@end