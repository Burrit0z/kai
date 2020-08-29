#import <CepheiPrefs/HBRootListController.h>
#import <Foundation/NSUserDefaults.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>

@interface PSListController (kai)
- (void)setFrame:(CGRect)frame;
@end

@interface NSTask : NSObject
@property (copy) NSArray *arguments;
@property (copy) NSString *launchPath;
- (id)init;
- (void)waitUntilExit;
- (void)launch;
@end

@interface KAIRootListController : HBRootListController
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;
@end

@interface Thomz_TwitterCell : PSTableCell
@end

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)arg1;
@end

@interface KaiHeaderCell : PSTableCell <PreferencesTableCustomView> {
    UIView *bgView;
    UILabel *packageNameLabel;
    UILabel *developerLabel;
    UILabel *versionLabel;
}
@end
