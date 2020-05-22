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
@property (nonatomic, strong) NSString *accessoryIdentifier;
-(id)glyph;
@end

@interface KAIBatteryCell : UIView
@property (nonatomic, strong) BCBatteryDevice *device;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, strong) UIImageView *glyphView;
@property (nonatomic, strong) _UIBatteryView *battery;
-(instancetype)initWithFrame:(CGRect)arg1 device:(BCBatteryDevice *)device;
-(void)updateInfo;
+(instancetype)cellForDeviceIfExists:(BCBatteryDevice *)device frameToCreateNew:(CGRect)arg2;
@end