#include <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#include <stdio.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "KAIBattery.mm"
#define KAISelf ((CSAdjunctListView *)self)

@interface UIApplication (Kai)
+(id)sharedApplication;
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface CSAdjunctListView : UIView
@property (nonatomic, assign) BOOL hasKai;
-(UIStackView *)stackView;
-(void)setStackView:(UIStackView *)arg1;
-(void)KaiUpdate;
@end

@interface SBDashBoardAdjunctListView : UIView
@property (nonatomic, assign) BOOL hasKai;
-(UIStackView *)stackView;
-(void)setStackView:(UIStackView *)arg1;
-(void)KaiUpdate;
@end

@interface CSMainPageView : UIView
-(void)updateForPresentation:(id)arg1;
@end

@interface _CSSingleBatteryChargingView : UIView
@end

@interface NSLayoutConstraint (Kai)
+(id)constraintWithAnchor:(id)arg1 relatedBy:(long long)arg2 toAnchor:(id)arg3 multiplier:(double)arg4 constant:(double)arg5 ;
@end

//prefs
BOOL enabled;


#define PLIST_PATH @"/User/Library/Preferences/com.burritoz.kaiprefs.plist"
#define kIdentifier @"com.burritoz.kaiprefs"
#define kSettingsChangedNotification (CFStringRef)@"com.burritoz.kaiprefs/reload"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.burritoz.kaiprefs.plist"

NSDictionary *prefs = nil;

static void *observer = NULL;

static void reloadPrefs() 
{
    if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) 
    {
        CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

        if (keyList) 
        {
            prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));

            if (!prefs) 
            {
                prefs = [NSDictionary new];
            }
            CFRelease(keyList);
        }
    } 
    else 
    {
        prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
    }
}

static BOOL boolValueForKey(NSString *key, BOOL defaultValue) {
    return (prefs && [prefs objectForKey:key] ? [[prefs objectForKey:key] boolValue] : defaultValue);
}


/*static double numberForValue(NSString *key, double defaultValue) {
	return (prefs && [prefs objectForKey:key] ? [[prefs objectForKey:key] doubleValue] : defaultValue);
}*/

static void preferencesChanged() 
{
    CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
    reloadPrefs();

    enabled = boolValueForKey(@"enabled", YES);
}