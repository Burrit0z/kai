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

@interface MTMaterialView : UIView
@property (nonatomic, assign) BOOL recipeDynamic;
-(id)_initWithRecipe:(NSInteger)arg1 configuration:(NSInteger)arg2 initialWeighting:(CGFloat)arg3 scaleAdjustment:(id)arg4;
+(id)materialViewWithRecipe:(NSInteger)arg1 options:(NSInteger)arg2 initialWeighting:(CGFloat)arg3 scaleAdjustment:(id)arg4;
@end

@interface BCBatteryDeviceController
@property (nonatomic, strong) NSArray *sortedDevices;
-(id)_sortedDevices;
+(id)sharedInstance;
@end

@interface BCBatteryDevice : NSObject
-(id)glyph;
@end

@interface KAIBattery : UIView
@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, assign) BOOL isUpdating;
+(KAIBattery *)sharedInstance;
-(instancetype)init;
-(void)updateBattery;
@end