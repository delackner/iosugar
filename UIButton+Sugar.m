#import "UIButton+Sugar.h"

@implementation UIButton (Sugar)

- (void) setTitle: (NSString*) s {
	[self setTitle: s forState: UIControlStateNormal];
}

- (NSString*) title {
	return [self titleForState: UIControlStateNormal];
}

- (void) setTitle: (NSString*) s scaleFrame: (BOOL) scale  {
    CGRect bFrame = self.frame;
    float originalSpace = self.superview.bounds.size.width - bFrame.size.width;
    float leftRatio = bFrame.origin.x / originalSpace;
    [self setTitle: s];
    CGSize tsz = [self.titleLabel.text sizeWithFont: self.titleLabel.font];
    tsz.width += 39; //OS3.0 UIButton width = textWidth + 39
	if (tsz.width > bFrame.size.width) {
		bFrame.size.width = tsz.width;
	}
	float newSpace = self.superview.bounds.size.width - bFrame.size.width;
    bFrame.origin.x = leftRatio * newSpace ;
	self.frame = bFrame;
}

- (void) useBackground: (NSString*) backgroundName {
	[self useBackground: backgroundName forState: UIControlStateNormal];
}

- (void) useBackground: (NSString*) backgroundName forState: (UIControlState) st {
	UIImage* img = [UIImage buttonBackgroundNamed: backgroundName size: self.frame.size];
	[self setBackgroundImage:img forState:st];
}

+ (UIButton*) buttonWithImage: (UIImage*) image touchImage: (UIImage*) hiImage {
	UIButton* b = [UIButton buttonWithType: UIButtonTypeCustom];
	[b setImage: image forState: UIControlStateNormal];
	[b setImage: hiImage forState: UIControlStateHighlighted];
	return b;
}

- (void) centerTitleBelowImage: (int) spacing floating: (BOOL) floating {
    CGSize i = self.imageView.frame.size;
    CGSize t = self.titleLabel.frame.size;
    
    if (floating) {
        self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - i.width, - (i.height + spacing), 0.0);
        t = self.titleLabel.frame.size;
        self.imageEdgeInsets = UIEdgeInsetsMake(-(t.height + spacing), 0.0, 0.0, - t.width);
    }
    else {
        self.titleEdgeInsets = UIEdgeInsetsMake(0, - i.width, - (i.height + spacing + t.height), 0.0);
        t = self.titleLabel.frame.size;
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0.0, 0.0, - t.width);
    }
}

- (void) centerTitleBelowImage: (int) spacing {
    [self centerTitleBelowImage: spacing floating: FALSE];
}

@end

@implementation StretchedButton

- (void) frameChanged {
	[self setBackgroundImage: [bgTemplate asButtonBackgroundOfSize: self.frame.size] forState: UIControlStateNormal];
}

- (void) awakeFromNib {
	[super awakeFromNib];
    bgTemplate = [self backgroundImageForState:UIControlStateNormal];
    [self frameChanged];
}

- (void) setFrame: (CGRect) f {
    CGSize osz = self.frame.size;
    [super setFrame: f];
    if (osz.width != f.size.width || osz.height != f.size.height) {
        [self frameChanged];
    }
}

@end

