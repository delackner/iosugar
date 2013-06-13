
@interface UIImage (Sugar)

+ (UIImage*)loadImage:(NSString*)aFilename;
- (UIImage *)crop:(CGRect)rect;
// image must be a standard width: 29 (left and right edges:14 middle:1) height: 46
+ (UIImage*) buttonBackgroundNamed:(NSString*) name size: (CGSize) bgSize ;
- (UIImage*)asButtonBackgroundOfSize: (CGSize) bgSize;
- (UIImage *)tintedWithColor:(UIColor *)theColor ;
- (UIImage *)tintedWithColor:(UIColor *)theColor blendMode: (CGBlendMode) mode;
- (UIImage *)tintedWithColor:(UIColor *)theColor blendMode: (CGBlendMode) mode scale: (float) scale;

- (UIImage*) grayImage ;
- (void) drawHorizontallyFlippedAtPoint: (CGPoint) p context: (CGContextRef) c;
- (void) drawHorizontallyFlippedAtPoint: (CGPoint) p context: (CGContextRef) c alpha: (float) alpha ;
- (void) drawCentered: (CGPoint) p;
- (void) drawCentered: (CGPoint) p alpha: (float) a;
- (UIImage*) imageWithBadge: (UIImage*) badge;
- (UIImage*) imageWithBadge: (UIImage*) badge dimmed: (float) dimmed;
- (void) savePNG: (NSString*) path;

@end
