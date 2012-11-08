

// only supports UIControlEventTouchDown, UIControlEventTouchUpInside, UIControlEventTouchUpOutside
@interface CustomButton : UIControl {
    __unsafe_unretained id target;
    __unsafe_unretained CALayer* hiLayer;
	UIImage* image;
	UIImage* selImage;
    NSMutableDictionary* actions;
}

@property (unsafe_unretained, nonatomic) UILabel* titleLabel;
//requires param to be a button, but declared as control so you can declare the buttons it will replace as UIControl
+ (id) replaceButton: (UIControl*) b;
- (id) initWithButton: (UIButton*) button;
- (UILabel*) makeTitleLabel; // subclasses can use custom label classes

@end

// only supports UIControlEventTouchDown, UIControlEventTouchUpInside, UIControlEventTouchUpOutside
// Not suitable for buttons that get enabled/disabled and have text, as the text is always just drawn with the enabled color.
@interface GlowButton : UIControl {
    __unsafe_unretained id target;
    __unsafe_unretained CALayer* glowLayer;
	UIImage* image;
	UIImage* selImage;
    NSMutableDictionary* actions;
}

- (id) initAndReplaceButton: (UIButton*) b;

@property (nonatomic, unsafe_unretained) UILabel* titleLabel;

@end

@interface DoubleButton: UIControl {
	__unsafe_unretained id target;
	UIImage* background;
	UIImage* image;
	UIImage* selImage;
	UIImage* hiImage;
	SEL selDouble;
	SEL selSingle;
    SEL selDown;
    SEL selUpOutside;
}
@property (nonatomic, strong) UIImage* background;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong) UIImage* selImage;
@property (nonatomic, strong) UIImage* hiImage;

- (id) initAndReplaceButton: (UIButton*) b;
- (void) setImage: (UIImage*) img forState: (UIControlState) s;
@end

@interface LongHoldButton: DoubleButton {
    UITouch* touch;
    int touchStartX, touchStartY;
	BOOL scheduled;
}
@end

#ifdef __cplusplus
extern "C" {
#endif

UIControl* ReplaceWithCustomButton(UIControl* c);
UIControl* ReplaceWithGlowButton(UIControl* c);
#define MAKE_GLOW_BUTTON(x) x = ReplaceWithGlowButton(x)

#ifdef __cplusplus
}
#endif
