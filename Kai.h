#include <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define KAISelf ((CSAdjunctListView *)self) //for use when calling self in KAITarget
#define afterMusicIndex(cls, obj) [[[cls sharedListViewForKai] stackView].subviews indexOfObject:obj]

@interface CSAdjunctListView : UIView
@property (nonatomic, assign) BOOL hasKai;
- (UIStackView *)stackView;
- (void)_layoutStackView;
- (void)setStackView:(UIStackView *)arg1;
+ (id)sharedListViewForKai;
@end

@interface CALayer (kai)
@property (nonatomic, assign) BOOL continuousCorners;
@end

@interface SBCoverSheetPrimarySlidingViewController : UIViewController
@end

@interface APEPlatter : UIView
@property (nonatomic, assign) BOOL removed;
+ (APEPlatter *)sharedInstance;
@end

@interface NCNotificationListView : UIView
- (void)fixComplicationsViewFrame;
@end

BOOL ios13 = NO;

BOOL isUpdating = NO;
BOOL shouldBeAdded = YES;

//prefs
BOOL enabled;
BOOL disableGlyphs;
BOOL hidePercent;
BOOL showAll;
BOOL belowMusic;
BOOL hideDeviceLabel;
BOOL hideChargingAnimation;
BOOL showAllMinusInternal;
BOOL hideBatteryIcon;
BOOL reAlignSelf;
BOOL showPhone;
BOOL removeForMedia;
BOOL extraPaddingAfter;
NSInteger bannerStyle;
NSInteger bannerAlign;
NSInteger textColor;
double spacing;
double glyphSize;
double bannerHeight;
double cornerRadius;
double bannerWidthFactor;
double horizontalOffset;
double bannerAlpha;
double kaiAlign;
double spacingHorizontal;

//by importing here, I can use vars in the .mm files
#import "KAIBatteryCell.mm"
#import "KAIBatteryPlatter.mm"
#import "KAIStackView.mm"

#define PLIST_PATH @"/User/Library/Preferences/com.burritoz.kaiprefs.plist"
#define kIdentifier @"com.burritoz.kaiprefs"
#define kSettingsChangedNotification (CFStringRef) @"com.burritoz.kaiprefs/reload"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.burritoz.kaiprefs.plist"

NSDictionary *prefs = nil;

static void *observer = NULL;

static void reloadPrefs() {
	if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
	    CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

		if (keyList) {
		    prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));

			if (!prefs) {
			    prefs = [NSDictionary new];
		    }
		    CFRelease(keyList);
	    }
	} else {
	    prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
	}
}

static BOOL boolValueForKey(NSString *key, BOOL defaultValue) {
    return (prefs && [prefs objectForKey:key] ? [[prefs objectForKey:key] boolValue] : defaultValue);
}

static double numberForValue(NSString *key, double defaultValue) {
    return (prefs && [prefs objectForKey:key] ? [[prefs objectForKey:key] doubleValue] : defaultValue);
}

static void preferencesChanged() {
    CFPreferencesAppSynchronize((CFStringRef)kIdentifier);
    reloadPrefs();

    enabled = boolValueForKey(@"enabled", YES);
    spacing = numberForValue(@"spacing", 5);
    glyphSize = numberForValue(@"glyphSize", 30);
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
    belowMusic = boolValueForKey(@"belowMusic", NO);
    hideChargingAnimation = boolValueForKey(@"hideChargingAnimation", YES);
    textColor = numberForValue(@"textColor", 0);
    bannerAlpha = numberForValue(@"bannerAlpha", 1);
    showAllMinusInternal = boolValueForKey(@"showAllMinusInternal", NO);
    kaiAlign = numberForValue(@"kaiAlign", 0);
    spacingHorizontal = numberForValue(@"spacingHorizontal", 8);
    hideBatteryIcon = boolValueForKey(@"hideBatteryIcon", NO);
    reAlignSelf = boolValueForKey(@"reAlignSelf", YES);
    extraPaddingAfter = boolValueForKey(@"extraPaddingAfter", NO);
    showPhone = boolValueForKey(@"showPhone", YES);
    removeForMedia = boolValueForKey(@"removeForMedia", NO);

	if (disableGlyphs) {
	    glyphSize = 0;
    }
}

static void applyPrefs() {
    preferencesChanged();

    isUpdating = YES;

    [[KAIBatteryPlatter sharedInstance] refreshForPrefs]; //so hard (not)
    [(CSAdjunctListView *)([KAIBatteryPlatter sharedInstance].superview.superview) _layoutStackView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KaiResetOffset" object:nil userInfo:nil];

    isUpdating = NO;
}