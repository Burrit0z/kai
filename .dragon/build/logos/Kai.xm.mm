#line 1 "Kai.xm"
#include <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#include <stdio.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "KAIBattery.mm"
BOOL setFrame = NO;
KAIBattery *batteryWidget;
CGRect original;








@interface UIApplication (Kai)
+(id)sharedApplication;
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface CSMainPageView : UIView
@property (nonatomic, strong) KAIBattery *battery;
-(void)updateForPresentation:(id)arg1;
@end




















#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class CSMainPageView; @class SBCoverSheetPrimarySlidingViewController; 
static void (*_logos_orig$_ungrouped$SBCoverSheetPrimarySlidingViewController$viewWillAppear$)(_LOGOS_SELF_TYPE_NORMAL SBCoverSheetPrimarySlidingViewController* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$_ungrouped$SBCoverSheetPrimarySlidingViewController$viewWillAppear$(_LOGOS_SELF_TYPE_NORMAL SBCoverSheetPrimarySlidingViewController* _LOGOS_SELF_CONST, SEL, BOOL); static void (*_logos_orig$_ungrouped$CSMainPageView$updateForPresentation$)(_LOGOS_SELF_TYPE_NORMAL CSMainPageView* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$CSMainPageView$updateForPresentation$(_LOGOS_SELF_TYPE_NORMAL CSMainPageView* _LOGOS_SELF_CONST, SEL, id); 

#line 47 "Kai.xm"
 

static void _logos_method$_ungrouped$SBCoverSheetPrimarySlidingViewController$viewWillAppear$(_LOGOS_SELF_TYPE_NORMAL SBCoverSheetPrimarySlidingViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BOOL arg1) {
	_logos_orig$_ungrouped$SBCoverSheetPrimarySlidingViewController$viewWillAppear$(self, _cmd, arg1);
	[batteryWidget updateBattery];
}





__attribute__((used)) static KAIBattery * _logos_method$_ungrouped$CSMainPageView$battery(CSMainPageView * __unused self, SEL __unused _cmd) { return (KAIBattery *)objc_getAssociatedObject(self, (void *)_logos_method$_ungrouped$CSMainPageView$battery); }; __attribute__((used)) static void _logos_method$_ungrouped$CSMainPageView$setBattery(CSMainPageView * __unused self, SEL __unused _cmd, KAIBattery * rawValue) { objc_setAssociatedObject(self, (void *)_logos_method$_ungrouped$CSMainPageView$battery, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }

static void _logos_method$_ungrouped$CSMainPageView$updateForPresentation$(_LOGOS_SELF_TYPE_NORMAL CSMainPageView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
	_logos_orig$_ungrouped$CSMainPageView$updateForPresentation$(self, _cmd, arg1);
	UIView *object = self;
	if(!setFrame) {
		original = self.frame;

		self.battery = [[KAIBattery alloc] initWithFrame:CGRectMake(8, 155, object.frame.size.width - 16, object.frame.size.height)];
		[self addSubview:self.battery];
		setFrame = YES;
		batteryWidget = self.battery;
	}

	object.frame = CGRectMake(
			original.origin.x,
			original.origin.y - (self.battery.number * 90),
			original.size.width,
			original.size.height + (self.battery.number * 90)
		);

	





































































}

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBCoverSheetPrimarySlidingViewController = objc_getClass("SBCoverSheetPrimarySlidingViewController"); MSHookMessageEx(_logos_class$_ungrouped$SBCoverSheetPrimarySlidingViewController, @selector(viewWillAppear:), (IMP)&_logos_method$_ungrouped$SBCoverSheetPrimarySlidingViewController$viewWillAppear$, (IMP*)&_logos_orig$_ungrouped$SBCoverSheetPrimarySlidingViewController$viewWillAppear$);Class _logos_class$_ungrouped$CSMainPageView = objc_getClass("CSMainPageView"); MSHookMessageEx(_logos_class$_ungrouped$CSMainPageView, @selector(updateForPresentation:), (IMP)&_logos_method$_ungrouped$CSMainPageView$updateForPresentation$, (IMP*)&_logos_orig$_ungrouped$CSMainPageView$updateForPresentation$);{ char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(KAIBattery *)); class_addMethod(_logos_class$_ungrouped$CSMainPageView, @selector(battery), (IMP)&_logos_method$_ungrouped$CSMainPageView$battery, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(KAIBattery *)); class_addMethod(_logos_class$_ungrouped$CSMainPageView, @selector(setBattery:), (IMP)&_logos_method$_ungrouped$CSMainPageView$setBattery, _typeEncoding); } } }
#line 151 "Kai.xm"
