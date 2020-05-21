#include "KAIRootListController.h"

NSBundle *tweakBundle;

@implementation KAIRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

-(void)viewWillAppear:(BOOL)arg1 {
	self.navigationController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.00 green: 0.735 blue: 0.965 alpha: 1.00];
    [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationController.navigationBar.translucent = NO;

	[[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[self.class]] setTintColor:[UIColor colorWithRed: 0.00 green: 0.82 blue: 1.00 alpha: 1.00]];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]] setOnTintColor:[UIColor colorWithRed: 0.00 green: 0.82 blue: 1.00 alpha: 1.00]];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[self.class]] setTintColor:[UIColor colorWithRed: 0.00 green: 0.82 blue: 1.00 alpha: 1.00]];

}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];

}

-(void)viewDidLoad {
	[super viewDidLoad];

	UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(respring:)];
    self.navigationItem.rightBarButtonItem = applyButton;

	self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.titleLabel.font = [UIFont systemFontOfSize:17.5];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"kai";
		self.titleLabel.alpha = 0.0;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationItem.titleView addSubview:self.titleLabel];

        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/kaiPrefs.bundle/icon.png"];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        self.iconView.alpha = 1.0;
        [self.navigationItem.titleView addSubview:self.iconView];

		[NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
            [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
            [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
            [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
            [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        ]];
}

-(void)respring:(id)sender {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.burritoz.kaiprefs/reload"), nil, nil, true);

	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Kai"
							message:@"Your settings have been applied. You can now go back to your lockscreen (CoverSheet) to see the changes. \n \n If some of your options did not apply, a respring might be necessary."
							preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Amazing!" style:UIAlertActionStyleDefault
		handler:^(UIAlertAction * action) {}];
		[alert addAction:defaultAction];

		[self presentViewController:alert animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 140) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }
}

@end

@implementation KaiHeaderCell // Header Cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)reuseIdentifier specifier:(id)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
    
    packageNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,90,self.contentView.bounds.size.width+30,50)];
	[packageNameLabel setTextAlignment:NSTextAlignmentRight];
    [packageNameLabel setFont:[UIFont systemFontOfSize:50 weight: UIFontWeightSemibold] ];
    packageNameLabel.textColor = [UIColor whiteColor];
    packageNameLabel.text = @"kai";
    
    developerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,50,self.contentView.bounds.size.width+30,50)];
	[developerLabel setTextAlignment:NSTextAlignmentRight];
    [developerLabel setFont:[UIFont systemFontOfSize:22.5 weight: UIFontWeightMedium] ];
    developerLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.85];
	developerLabel.alpha = 0.8;
    developerLabel.text = @"Burrit0z";
    
    
    versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,130,self.contentView.bounds.size.width+30,50)];
	[versionLabel setTextAlignment:NSTextAlignmentRight];
    [versionLabel setFont:[UIFont systemFontOfSize:22 weight: UIFontWeightMedium] ];
    versionLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
	versionLabel.alpha = 0.8;
    versionLabel.text = @"alpha";

	NSBundle *bundle = [[NSBundle alloc]initWithPath:@"/Library/PreferenceBundles/kaiPrefs.bundle"];
	UIImage *phone = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"kai" ofType:@"png"]];
	UIImageView *phoneImage = [[UIImageView alloc]initWithImage:phone];
	[phoneImage setFrame:CGRectMake(40,40,190,160)];
    phoneImage.clipsToBounds = YES;
    
    bgView.backgroundColor = [UIColor colorWithRed: 0.00 green: 0.82 blue: 1.00 alpha: 1.00];
    
    [self addSubview:packageNameLabel];
    [self addSubview:developerLabel];
    [self addSubview:versionLabel];
	[self addSubview:phoneImage];

    }
    	return self;

}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KaiHeaderCell" specifier:specifier];
}

- (void)setFrame:(CGRect)frame {
	frame.origin.x = 0;
	//frame.origin.y = 43;
	[super setFrame:frame];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1{
    return 200.0f;
}


-(void)layoutSubviews{
	[super layoutSubviews];

    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, 200)];

    UIColor *topColor = [UIColor colorWithRed: 0.00 green: 0.82 blue: 1.00 alpha: 1.00];
    UIColor *bottomColor = [UIColor colorWithRed: 0.23 green: 0.48 blue: 0.84 alpha: 1.00];

    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects: (id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    theViewGradient.startPoint = CGPointMake(0.5, 0.0);
    theViewGradient.endPoint = CGPointMake(0.5, 1.0);
    theViewGradient.frame = bgView.bounds;

    //Add gradient to view
    [bgView.layer insertSublayer:theViewGradient atIndex:0];
    [self insertSubview:bgView atIndex:0];

}


- (CGFloat)preferredHeightForWidth:(CGFloat)width inTableView:(id)tableView {
	return [self preferredHeightForWidth:width];
}

@end
