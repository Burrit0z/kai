#include "KAIRootListController.h"

KAIRootListController *controller;
NSBundle *tweakBundle;

//thank god for renai
static inline NSString *getPackageVersion() {
    NSString *packageVersion = [NSString stringWithFormat:@"${%@}", @"Version"];
    int status;

    NSMutableArray<NSString *> *argsv0 = [NSMutableArray array];
	for (NSString *string in @[ @"/usr/bin/dpkg-query", @"-Wf", packageVersion, @"com.burritoz.kai" ]) {
	    [argsv0
		addObject:[NSString stringWithFormat:@"'%@'",
						     [string stringByReplacingOccurrencesOfString:@"'"
										       withString:@"\\'"
											  options:NSRegularExpressionSearch
											    range:NSMakeRange(
												      0, string.length)]]];
	}

    NSString *argsv1 = [argsv0 componentsJoinedByString:@" "];
    FILE *file = popen(argsv1.UTF8String, "r");
	if (!file) {
	    return nil;
    }

    char data[1024];
    NSMutableString *output = [NSMutableString string];

	while (fgets(data, 1024, file) != NULL) {
	    [output appendString:[NSString stringWithUTF8String:data]];
	}

    int result = pclose(file);
    status = result;

	if (status == 0) {
	    return output ?: @"🏴‍☠️ Pirated";
    }

    return @"🏴‍☠️ Pirated";
}

////////

static void respringNeeded() {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Respring"
								   message:@"Changing this requires a respring for it to take effect. Would you like to respring now?"
							    preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"No"
							    style:UIAlertActionStyleCancel
							  handler:^(UIAlertAction *action){
							  }];

    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Respring"
						  style:UIAlertActionStyleDestructive
						handler:^(UIAlertAction *action) {
						  NSTask *t = [[NSTask alloc] init];
						  [t setLaunchPath:@"usr/bin/killall"];
						  [t setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
						  [t launch];
						}];

    [alert addAction:defaultAction];
    [alert addAction:yes];
    [controller presentViewController:alert animated:YES completion:nil];
}

static void applyPrefs() {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.burritoz.kaiprefs/reload"), nil, nil, true);
}

@implementation KAIRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
	    _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }

    return _specifiers;
}

- (void)viewWillAppear:(BOOL)arg1 {
    [[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[ self.class ]] setTintColor:[UIColor colorWithRed:0.00 green:0.82 blue:1.00 alpha:1.00]];
    [[UISwitch appearanceWhenContainedInInstancesOfClasses:@[ self.class ]] setOnTintColor:[UIColor colorWithRed:0.00 green:0.82 blue:1.00 alpha:1.00]];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[ self.class ]] setTintColor:[UIColor colorWithRed:0.00 green:0.82 blue:1.00 alpha:1.00]];
}

- (void)viewWillDisappear:(BOOL)arg1 {
    [super viewWillDisappear:arg1];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.titleView = [UIView new];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.titleLabel.font = [UIFont systemFontOfSize:17.5];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.text = @"kai";
    self.titleLabel.alpha = 0.0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.navigationItem.titleView addSubview:self.titleLabel];

    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
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

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Pirated :("
								   message:@"Please install kai from Chariz repository."
							    preferredStyle:UIAlertControllerStyleAlert];

	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.burritoz.kai.list"] && [[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.burritoz.kai.md5sums"]) {
	    // nothing
	} else {
	    [self presentViewController:alert animated:YES completion:nil];
	}

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)respringNeeded, CFSTR("com.burritoz.kaiprefs.respringneeded"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)applyPrefs, CFSTR("com.burritoz.kaiprefs.apply"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

    controller = self;
}

- (void)resetPrefs:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Preferences"
								   message:@"Are you sure you want to reset all of your preferences? This action CANNOT be undone! Your device will respring."
							    preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"No"
							    style:UIAlertActionStyleDefault
							  handler:^(UIAlertAction *action){
							  }];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes"
						  style:UIAlertActionStyleDestructive
						handler:^(UIAlertAction *action) {
						  NSUserDefaults *prefs = [[NSUserDefaults standardUserDefaults] init];
						  [prefs removePersistentDomainForName:@"com.burritoz.kaiprefs"];

						  NSTask *f = [[NSTask alloc] init];
						  [f setLaunchPath:@"/usr/bin/killall"];
						  [f setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
						  [f launch];
						}];

    [alert addAction:defaultAction];
    [alert addAction:yes];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;

	if (offsetY > 120) {
	    [UIView animateWithDuration:0.2
			     animations:^{
			       self.iconView.alpha = 1.0;
			       self.titleLabel.alpha = 0.0;
			     }];
	} else {
	    [UIView animateWithDuration:0.2
			     animations:^{
			       self.iconView.alpha = 0.0;
			       self.titleLabel.alpha = 1.0;
			     }];
	}
}

- (void)followMeBurritoz {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/burrit0ztweaks"]];
}

- (void)followMeOnTwitterThomz {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/thomzi07"]];
}

@end

@implementation KaiHeaderCell // Header Cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)reuseIdentifier specifier:(id)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
	    UILabel *tweakLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, self.contentView.bounds.size.width + 30, 50)];
	    [tweakLabel setTextAlignment:NSTextAlignmentLeft];
	    [tweakLabel setFont:[UIFont systemFontOfSize:50 weight:UIFontWeightRegular]];
	    tweakLabel.text = @"kai";

	    UILabel *devLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, self.contentView.bounds.size.width + 30, 50)];
	    [devLabel setTextAlignment:NSTextAlignmentLeft];
	    [devLabel setFont:[UIFont systemFontOfSize:20 weight:UIFontWeightMedium]];
	    devLabel.alpha = 0.8;
	    devLabel.text = getPackageVersion();

	    NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/kaiPrefs.bundle"];
	    UIImage *logo = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"iconFullSize" ofType:@"png"]];
	    UIImageView *icon = [[UIImageView alloc] initWithImage:logo];
	    icon.frame = CGRectMake(self.contentView.bounds.size.width - 35, 35, 70, 70);
	    icon.translatesAutoresizingMaskIntoConstraints = NO;

	    [self addSubview:tweakLabel];
	    [self addSubview:devLabel];
	    [self addSubview:icon];

	    [icon.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-20].active = YES;
	    [icon.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
	    [icon.widthAnchor constraintEqualToConstant:70].active = YES;
	    [icon.heightAnchor constraintEqualToConstant:70].active = YES;

	    icon.layer.masksToBounds = YES;
	    icon.layer.cornerRadius = 15;
    }

    return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KaiHeaderCell" specifier:specifier];
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x = 0;
    [super setFrame:frame];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
    return 140.0f;
}

@end

@implementation Thomz_TwitterCell // lil copy of HBTwitterCell from Cephei
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
	    UILabel *User = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, 200, 20)];
	    [User setText:specifier.properties[@"user"]];
	    [User setFont:[User.font fontWithSize:15]];

	    UILabel *Description = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, 200, 20)];
	    [Description setText:specifier.properties[@"description"]];
	    [Description setFont:[Description.font fontWithSize:10]];

	    NSBundle *bundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/kaiPrefs.bundle"];

	    UIImage *profilePicture;
	    profilePicture = [UIImage imageWithContentsOfFile:[bundle pathForResource:specifier.properties[@"image"] ofType:@"jpg"]];
	    UIImageView *profilePictureView = [[UIImageView alloc] initWithImage:profilePicture];
	    [profilePictureView.layer setMasksToBounds:YES];
	    [profilePictureView.layer setCornerRadius:20];
	    [profilePictureView setFrame:CGRectMake(15, 15, 40, 40)];

	    [self addSubview:User];
	    [self addSubview:Description];
	    [self addSubview:profilePictureView];
    }

    return self;
}

@end