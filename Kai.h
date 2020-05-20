#include <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#include <stdio.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

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

@interface CALayer (kai)
@property (nonatomic, assign) BOOL continuousCorners;
@end

BOOL isUpdating = NO;

//prefs
BOOL enabled;
BOOL disableGlyphs;
BOOL hidePercent;
BOOL showAll;
BOOL hideDeviceLabel;
NSInteger bannerStyle;
NSInteger bannerAlign;
double spacing;
double glyphSize;
double bannerHeight;
double cornerRadius;
double bannerWidthFactor;
double horizontalOffset;

#import "KAIBattery.mm"

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


static double numberForValue(NSString *key, double defaultValue) {
	return (prefs && [prefs objectForKey:key] ? [[prefs objectForKey:key] doubleValue] : defaultValue);
}

static void preferencesChanged() 
{
    CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
    reloadPrefs();

    enabled = boolValueForKey(@"enabled", YES);
    spacing = numberForValue(@"spacing", 5);
    glyphSize = numberForValue(@"glyphSize", 35);
    bannerHeight = numberForValue(@"bannerHeight", 80);
    cornerRadius = numberForValue(@"cornerRadius", 13);
    disableGlyphs = boolValueForKey(@"disableGlyphs", NO);
    hidePercent = boolValueForKey(@"hidePercent", NO);
    bannerStyle = numberForValue(@"bannerStyle", 1);
    showAll = boolValueForKey(@"showAll", NO);
    bannerWidthFactor = numberForValue(@"bannerWidthFactor", 0);
    hideDeviceLabel = boolValueForKey(@"hideDeviceLabel", NO);
    bannerAlign = numberForValue(@"bannerAlign", 2);
    horizontalOffset = numberForValue(@"horizontalOffset", 0);

    if(disableGlyphs) {
        glyphSize = 0;
    }
}

static void applyPrefs() 
{
    preferencesChanged();
    isUpdating = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [KAIBattery sharedInstance].alpha = 0;
    } completion:^(BOOL finished){
        [[KAIBattery sharedInstance] updateBattery];
        [(CSAdjunctListView *)([KAIBattery sharedInstance].superview.superview) KaiUpdate];
        [UIView animateWithDuration:0.35 animations:^{
            [KAIBattery sharedInstance].alpha = 1;
        } completion:^(BOOL finished){
            isUpdating = NO;
        }];
    }];

}