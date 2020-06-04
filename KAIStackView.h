@interface KAIStackView : UIStackView
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@end

@interface KAIBatteryPlatter : UIScrollView <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *stackHolder;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, assign) NSInteger oldCountOfDevices;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *subviewAligner;
@property (nonatomic, strong) KAIStackView *stack;
@property (nonatomic, assign) BOOL isUpdating;
@property (nonatomic, assign) BOOL queued;
+(KAIBatteryPlatter *)sharedInstance;
-(instancetype)initWithFrame:(CGRect)arg1;
-(void)refreshForPrefs;
-(void)updateBattery;
-(void)calculateHeight;
@end