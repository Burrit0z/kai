@interface KAIBatteryStack : UIStackView
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) NSInteger oldCountOfDevices;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, assign) BOOL isUpdating;
@property (nonatomic, assign) BOOL queued;
+(KAIBatteryStack *)sharedInstance;
-(instancetype)init;
-(void)refreshForPrefs;
-(void)updateBattery;
@end