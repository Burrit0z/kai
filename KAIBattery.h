@interface KAIBattery : UIView
@property (nonatomic, strong) NSMutableArray *displayingDevices;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, assign) BOOL isUpdating;
+(KAIBattery *)sharedInstance;
-(instancetype)init;
-(void)removeAllAndRefresh;
-(void)updateBattery;
@end