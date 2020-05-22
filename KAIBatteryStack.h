@interface KAIBatteryStack : UIStackView
@property (nonatomic, strong) NSMutableArray *displayingDevices;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, assign) BOOL isUpdating;
+(KAIBatteryStack *)sharedInstance;
-(instancetype)init;
-(void)removeAllAndRefresh;
-(void)updateBattery;
@end