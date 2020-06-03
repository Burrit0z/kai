#import "KAIStackView.h"

@implementation KAIStackView

-(id)initWithFrame:(CGRect)arg1 {
    self = [super initWithFrame:arg1];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return self;
}

-(void)addSubview:(UIView *)view {
    [super addSubview:view];
    [(UIScrollView *)self.superview setContentSize:self.frame.size];

    if(textColor==0 && [view respondsToSelector:@selector(updateInfo)]) {
        KAIBatteryCell *cell = (KAIBatteryCell *)view;
        if(@available(iOS 12.0, *)) {
			if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                [cell.label setTextColor:[UIColor whiteColor]];
                [cell.percentLabel setTextColor:[UIColor whiteColor]];
            } else if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                [cell.label setTextColor:[UIColor blackColor]];
                [cell.percentLabel setTextColor:[UIColor blackColor]];   
            }
        }
    }
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [(KAIBatteryPlatter *)(self.superview) calculateHeight];
}

@end