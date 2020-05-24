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

        NSLog(@"kai: devices are %@", devices);
 
        for(KAIBatteryCell *cell in self.subviews) {
            //BCBatteryDevice *device = cell.device;
            [cell updateInfo];
        }
        
        for (BCBatteryDevice *device in devices) {
            KAIBatteryCell *cell = [device kaiCellForDevice];

            [cell updateInfo];
            BOOL shouldAdd = NO;

            if(showAll) {
                shouldAdd = YES;
            } else if(!showAll && device.charging) {
                shouldAdd = YES;
            }

            if(![self.subviews containsObject:cell] && shouldAdd && [devices containsObject:device]) {
                [cell setFrame:CGRectMake(0,0,self.frame.size.width, bannerHeight + spacing)];
                [self addArrangedSubview:cell];
            } else {
                [self removeArrangedSubview:cell];
            }

            if(!cell.height) {
                
                cell.height.active = NO;
                cell.height = [cell.heightAnchor constraintEqualToConstant:(bannerHeight + spacing)];
                cell.height.active = YES;

            } else {
                int height = (bannerHeight + spacing);
                cell.height.constant = height;

                UIStackView *s = self;
                s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, (s.frame.size.height - 1));
            }

            if(!cell.width) {
                
                cell.width.active = NO;
                cell.width = [cell.widthAnchor constraintEqualToConstant:(self.frame.size.width)];
                cell.width.active = YES;

            } else {
                int width = self.frame.size.width;
                cell.width.constant = width;

                UIStackView *s = self;
                s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, (s.frame.size.height - 1));
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

-(void)removeAllAndRefresh {
    for( UIView *view in self.subviews ) {
        @try {
            [view removeFromSuperview];
        } @catch (NSException *exception) {
            //Panik
        }
    }
    [KAIBatteryCell resetArray];
    [self updateBattery];
}

+(KAIBatteryStack *)sharedInstance {
    return instance;
}

@end