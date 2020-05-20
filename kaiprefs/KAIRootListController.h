#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListItemsController.h>
#import <Foundation/NSUserDefaults.h>

@interface PSListController (kai)
-(void)setFrame:(CGRect)frame;
@end

@interface KAIRootListController : PSListController
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
