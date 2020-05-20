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
	self.navigationController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.00 green: 0.77 blue: 0.95 alpha: 1.00];
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

	NSBundle *bundle = [[NSBundle alloc]initWithPath:@"/Library/PreferenceBundles/KaiPrefs.bundle"];
	UIImage *phone = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"kai" ofType:@"png"]];
	UIImageView *phoneImage = [[UIImageView alloc]initWithImage:phone];
	[phoneImage setFrame:self.frame];
    
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
