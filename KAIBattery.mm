#import "KAIBattery.h"

KAIBattery *instance;
NSMutableArray *addedCells = [[NSMutableArray alloc] init];

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
        NSLog(@"kai: battery platter called to update");
    if(!self.isUpdating) {
    self.isUpdating = YES;
    self.number = 0;
    float y = 0;
    BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
            NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");

            /*for( UIView *view in self.subviews ) {
                @try {
                    [view removeFromSuperview];
                } @catch (NSException *exception) {
                    //Panik
                }
            }*/

            for(KAIBatteryCell *cell in addedCells) {
                if(![devices containsObject:cell.device]) {
                    cell.device = nil;
                    [cell removeFromSuperview];
                    [self.displayingDevices removeObject:cell.label.text]; //lmaoo
                } else {
                    [cell updateInfo];
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
                    NSLog(@"Kai: SHOULD ADD");
                } else if(!showAll && charging) {
                    shouldAdd = YES;
                    NSLog(@"Kai: SHOULD ADD");
                }

                KAIBatteryCell *cell = [KAIBatteryCell cellForDeviceIfExists:device];

                /*
                @property (nonatomic, assign) BOOL lastChargingState;
                @property (nonatomic, assign) BOOL lastLPM;
                @property (nonatomic, assign) double lastPercent;
                */

                if(shouldAdd && [deviceName length]!=0) {

                    if(cell==nil && ![self.displayingDevices containsObject:deviceName]) {
                        KAIBatteryCell *newCell = [[KAIBatteryCell alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width, bannerHeight) device:device];
                        [self addSubview:newCell];
                        [self.displayingDevices addObject:deviceName];
                        [addedCells addObject:newCell];
                        //y+=bannerHeight + spacing;
                    }
                    //self.number +=1;
                    y+=bannerHeight + spacing;

                } else if(!shouldAdd) {

                    if([self.displayingDevices containsObject:deviceName]) {
                        [cell removeFromSuperview];
                        [self.displayingDevices removeObject:deviceName];
                    }

                }
            }
            //[self.heightAnchor constraintEqualToConstant:(self.number * 85)].active = YES;
            self.isUpdating = NO;
            self.number = [self.subviews count];
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

    self.displayingDevices = [[NSMutableArray alloc] init];

    addedCells = nil;
    [self updateBattery];
}

+(KAIBattery *)sharedInstance {
    return instance;
}

@end