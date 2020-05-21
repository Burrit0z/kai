#import "KAIBattery.h"

KAIBattery *instance;
@implementation KAIBattery

-(instancetype)init {
    self = [super init];
    instance = self;
    if (self) {
        [self updateBattery];
        self.userInteractionEnabled = NO;
    }
    return self;
}

long long batteryPercentage;
long long lastPercentage;

-(void)updateBattery {
    dispatch_async(dispatch_get_main_queue(), ^{
    if(!self.isUpdating) {
    self.isUpdating = YES;
    self.number = 0;
    float y = 0;
    BCBatteryDeviceController *bcb = [BCBatteryDeviceController sharedInstance];
            NSArray *devices = MSHookIvar<NSArray *>(bcb, "_sortedDevices");

            for( UIView *view in self.subviews ) {
                @try {
                    [view removeFromSuperview];
                } @catch (NSException *exception) {
                    //Panik
                }
            }

            for (BCBatteryDevice *device in devices) {
                //NSString *deviceName = MSHookIvar<NSString *>(device, "_name");
                double batteryPercentage = MSHookIvar<long long>(device, "_percentCharge");
                BOOL charging = MSHookIvar<long long>(device, "_charging");
                BOOL LPM = MSHookIvar<BOOL>(device, "_batterySaverModeActive");

                BOOL shouldAdd = NO;

                if(showAll) {
                    shouldAdd = YES;
                } else if(!showAll && charging) {
                    shouldAdd = YES;
                }

                BOOL shouldRefresh = NO;

                KAIBatteryCell *cell = [KAIBatteryCell cellForDeviceIfExists:device];

                /*
                @property (nonatomic, assign) BOOL lastChargingState;
                @property (nonatomic, assign) BOOL lastLPM;
                @property (nonatomic, assign) double lastPercent;
                */
                if(cell.lastChargingState != charging || cell.lastLPM != LPM || cell.lastPercent != batteryPercentage) {
                    shouldRefresh = YES;
                }

                if(shouldAdd) {

                    if([self.displayingDevices containsObject:device] && shouldRefresh) {
                        [cell updateInfo];
                    } else if(![self.displayingDevices containsObject:device]) {
                        KAIBatteryCell *newCell = [[KAIBatteryCell alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width, self.frame.size.width)];
                        [self addSubview:newCell];
                        [self.displayingDevices addObject:device];
                        y+=bannerHeight + spacing;
                        self.number +=1;
                    }

                } else if(!shouldAdd) {

                    if([self.displayingDevices containsObject:device]) {
                        [cell removeFromSuperview];
                        [self.displayingDevices removeObject:device];
                    }

                }
            }
            //[self.heightAnchor constraintEqualToConstant:(self.number * 85)].active = YES;
            self.isUpdating = NO;
        }
    });
}

+(KAIBattery *)sharedInstance {
    return instance;
}

@end