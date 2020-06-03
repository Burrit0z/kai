@interface KAIBatteryPlatter : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) NSInteger oldCountOfDevices;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) KAIStackView *stack;
@property (nonatomic, assign) BOOL isUpdating;
@property (nonatomic, assign) BOOL queued;
+(KAIBatteryPlatter *)sharedInstance;
-(instancetype)initWithFrame:(CGRect)arg1;
-(void)refreshForPrefs;
-(void)updateBattery;
-(void)calculateHeight;
@end