#import "KAIStackView.h"

@implementation KAIStackView

-(id)initWithFrame:(CGRect)arg1 {
    self = [super initWithFrame:arg1];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return self;
}

-(void)addSubview:(UIView *)arg1 {
    [super addSubview:arg1];
    [(UIScrollView *)self.superview setContentSize:self.frame.size];
}

@end