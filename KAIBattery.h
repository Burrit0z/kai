#import <UIKit/UIKit.h>
#import <substrate.h>

@interface _UIBatteryView : UIView
@property (nonatomic, assign) CGFloat chargePercent;
@property (nonatomic, assign) CGFloat bodyColorAlpha;
@property (nonatomic, assign) CGFloat pinColorAlpha;
@property (nonatomic, assign) BOOL showsPercentage;
@property (nonatomic, assign) BOOL saverModeActive;
@property (nonatomic, assign) BOOL showsInlineChargingIndicator;
@property (nonatomic, assign) NSInteger chargingState;
@end

@interface BCBatteryDeviceController
@property (nonatomic, strong) NSArray *sortedDevices;
-(id)_sortedDevices;
+(id)sharedInstance;
@end

@interface BCBatteryDevice : BCBatteryDeviceController
-(id)glyph;
@end

@interface KAIBattery : UIView
@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) BOOL isUpdating;
+(KAIBattery *)sharedInstance;
-(instancetype)initWithFrame:(CGRect)arg1;
-(void)updateBattery;
@end