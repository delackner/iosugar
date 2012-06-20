@interface UIButton (Sugar)
- (void) setTitle: (NSString*) s;
- (void) setTitle: (NSString*) s scaleFrame: (BOOL) scale;
- (NSString*) title ;
- (void) useBackground: (NSString*) backgroundName;
- (void) useBackground: (NSString*) backgroundName forState: (UIControlState) st;
+ (UIButton*) buttonWithImage: (UIImage*) image touchImage: (UIImage*) hiImage ;

- (void) centerTitleBelowImage: (int) spacing floating: (BOOL) floating; // image and text are centered vertically
- (void) centerTitleBelowImage: (int) spacing; // image is centered vertically.  text is below it.
@end

@interface StretchedButton : UIButton {
    UIImage* bgTemplate;
}
@end