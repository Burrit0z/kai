@interface KAIBatteryPlatter : UIStackView
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) NSInteger oldCountOfDevices;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) KAIStackView *stack;
@property (nonatomic, assign) BOOL isUpdating;
@property (nonatomic, assign) BOOL queued;
+(KAIBatteryPlatter *)sharedInstance;
-(instancetype)init;
-(void)refreshForPrefs;
-(void)updateBattery;
@end