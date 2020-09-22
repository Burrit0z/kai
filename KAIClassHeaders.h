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
- (id)_initWithRecipe:(NSInteger)arg1 configuration:(NSInteger)arg2 initialWeighting:(CGFloat)arg3 scaleAdjustment:(id)arg4;
+ (id)materialViewWithRecipe:(NSInteger)arg1 options:(NSInteger)arg2 initialWeighting:(CGFloat)arg3 scaleAdjustment:(id)arg4;
@end

@interface BCBatteryDeviceController : NSObject
@property (nonatomic, strong) NSArray *sortedDevices;
- (id)_sortedDevices;
- (id)connectedDevices; //ios 14
+ (id)sharedInstance;
@end

@interface BCBatteryDevice : NSObject
@property (nonatomic, strong) id kaiCell;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) long long percentCharge;
@property (nonatomic, assign, getter=isCharging) BOOL charging;
@property (nonatomic, assign, getter=isFake) BOOL fake;
@property (nonatomic, assign, getter=isInternal) BOOL internal;
@property (nonatomic, assign, getter=isBatterySaverModeActive) BOOL batterySaverModeActive;
@property (nonatomic, strong) NSString *identifier;
- (id)glyph; //ios 13
- (id)batteryWidgetGlyph; //ios 14
- (id)kaiCellForDevice;
- (void)resetKaiCellForNewPrefs;
@end

@interface KAIBatteryCell : UIView
@property (nonatomic, weak) BCBatteryDevice *device;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, strong) UIImageView *glyphView;
@property (nonatomic, strong) _UIBatteryView *battery;
- (instancetype)initWithFrame:(CGRect)arg1 device:(BCBatteryDevice *)device;
- (void)updateInfo;
@end

@interface KAIStackView : UIStackView
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@end

@interface KAIBatteryPlatter : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, assign) BOOL shouldUpdate;
@property (nonatomic, strong) UIView *stackHolder;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) NSInteger oldCountOfDevices;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *subviewAligner;
@property (nonatomic, strong) KAIStackView *stack;
@property (nonatomic, assign) BOOL isUpdating;
@property (nonatomic, assign) BOOL queued;
+ (KAIBatteryPlatter *)sharedInstance;
- (instancetype)initWithFrame:(CGRect)arg1;
- (void)resetOffset;
- (void)refreshForPrefs;
- (void)updateBattery;
- (void)calculateHeight;
@end

@interface UIView (kai)
- (void)_didRemoveSubview:(UIView *)arg1;
@end