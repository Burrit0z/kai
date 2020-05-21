@interface KAIBattery : UIView
@property (nonatomic, strong) NSMutableArray *displayingDevices;
@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, assign) BOOL isUpdating;
+(KAIBattery *)sharedInstance;
-(instancetype)init;
-(void)updateBattery;
@end