#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#import "UIView+Sugar.h"

@implementation UIView(Sugar)

- (void) setFrameOrigin: (CGPoint) p {
	CGRect f = self.frame;
	f.origin = p;
	self.frame= f;
}

- (void) setFrameX: (int) x {
    CGRect f = self.frame;
    f.origin.x = x;
    self.frame = f;
}

- (void) setFrameY: (int) y {
    CGRect f = self.frame;
    f.origin.y = y;
    self.frame = f;
}

- (void) setFrameW: (int) w {
    CGRect f = self.frame;
    f.size.width = w;
    self.frame = f;
}

- (void) setFrameH: (int) h {
    CGRect f = self.frame;
    f.size.height = h;
    self.frame = f;
}

- (void) snapToCenterX {
    CGPoint sp = self.superview.center;
    self.center = CGPointMake(sp.x, self.center.y);
}

static char slideFrameKey;

- (void) saveFrame {
    objc_setAssociatedObject(self, &slideFrameKey, NSStringFromCGRect(self.frame), OBJC_ASSOCIATION_COPY);
}

- (void) loadFrame {
    NSString* s = objc_getAssociatedObject(self, &slideFrameKey);
    self.frame = CGRectFromString(s);
}

- (UIImage*) asImage {
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) addSubviewWithFade: (UIView*) v {
	[self addSubviewWithFade: v delegate: self endSelector: nil context: nil];
}

- (void) addSubviewWithFade: (UIView*) v delegate: (id) d endSelector: (SEL) s context: (id) context{
    if (![v superview]) {
        [self addSubview: v];
    }
	v.alpha = 0;
	[UIView beginAnimations: nil context: (__bridge void*) context];
	if (s) {
		[UIView setAnimationDelegate: d];
		[UIView setAnimationDidStopSelector: s];
	}
	//	[UIView setAnimationDuration: 0.3];
	v.alpha = 1;
	[UIView commitAnimations];
}

- (void) replaceWithFade: (UIView*) v {
	[[self superview] addSubview: v];
	v.alpha = 0;
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(replaceWithFade_:finished:context:)];
	//	[UIView setAnimationDuration: 0.3];
	v.alpha = 1;
	[UIView commitAnimations];
}

- (void) replaceWithFade_: (NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self removeFromSuperview];
}

- (UIViewController*) replaceWithViewFromNib: (NSString*) className {
    UIViewController* m = [[NSClassFromString(className) alloc] initWithNibName:className bundle:[NSBundle mainBundle]];
	[self replaceWithFade: m.view];
	return m;
}

- (void) beginRemovalAnimation {
    [UIView beginAnimations: nil context: nil];
}

- (void) endRemovalAnimation {
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(transitionFinishedSoRemove:finished:context:)];
	[UIView commitAnimations];
}

- (void)transitionFinishedSoRemove:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self removeFromSuperview];
}

- (void) removeWithFade {
    [self beginRemovalAnimation];
	self.alpha = 0;
    [self endRemovalAnimation];
}

- (void) removeWithFadeDuration:(NSTimeInterval) secs {
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationDuration: secs];
	self.alpha = 0;
	[UIView commitAnimations];
	[self removeFromSuperview];
}

- (void) addSubviewWithFlip: (UIView*) v {
	[self addSubview: v];
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.window cache: YES];
	[UIView commitAnimations];
}

- (void) removeWithFlip {
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.window cache: YES];
	[UIView commitAnimations];
	[self removeFromSuperview];
}

- (void) addSubviewWithLocalFlip: (UIView*) v {
	[self addSubview: v];
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self cache: YES];
	[UIView commitAnimations];
}

- (void) removeWithLocalFlip {
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.superview cache: YES];
	[UIView commitAnimations];
	[self removeFromSuperview];
}

- (void) addSubviewWithCurlUp: (UIView*) v {
	[self addSubview: v];
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.window cache: YES];
	[UIView commitAnimations];
}

- (void) removeWithCurlDown {
	[UIView beginAnimations: nil context: nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.window cache: YES];
	[UIView commitAnimations];
	[self removeFromSuperview];
}

CGRect OffscreenFrameForSlideEdge(UIView* v, ScreenEdge edge) {
	CGRect f = v.frame;
	if (ScreenEdgeLeft == edge) {
		f.origin.x = -f.size.width;
	}
	else if (ScreenEdgeRight == edge) {
		f.origin.x = v.superview.bounds.size.width;
	}
	else if (ScreenEdgeTop == edge) {
		f.origin.y = -f.size.height;
	}
	else if (ScreenEdgeBottom == edge) {
		f.origin.y = v.superview.bounds.size.height;
	}
	return f;
}

- (void) slideView: (UIView*) v toPoint: (CGPoint) p {
	[self slideView: v toPoint: p fromScreenEdge: ScreenEdgeRight];
}

- (void) slideView: (UIView*) v toPoint: (CGPoint) p fromUnderView: (UIView*) cover {
	if (![v superview]) {
		CGRect f = v.frame;
        f.origin = CGPointMake(p.x, cover.frame.origin.y);
        v.frame = f;
		[self insertSubview:v belowSubview: cover];
        
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationDuration: 0.2];//0.5
		f.origin = p;
		v.frame = f;
		[UIView commitAnimations];
	}
	else {
		[UIView beginAnimations: nil context: (__bridge void*)v];
		[UIView setAnimationDuration: 0.2];//0.5
		CGRect f = v.frame;
        f.origin = CGPointMake(p.x, cover.frame.origin.y);
        v.frame = f;
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(slideFinishedSoRemove:finished:context:)];
		[UIView commitAnimations];
	}
}

- (void) slideView: (UIView*) v toPoint: (CGPoint) p fromScreenEdge: (ScreenEdge) edge
{
    [self slideView: v toPoint: p fromScreenEdge: edge completion: nil];
}

- (void) slideView: (UIView*) v toPoint: (CGPoint) p fromScreenEdge: (ScreenEdge) edge completion: (void(^)(BOOL finished))completion {
	if (![v superview]) {
		[self addSubview: v];
		CGRect f = OffscreenFrameForSlideEdge(v, edge);
		if (ScreenEdgeRight == edge || ScreenEdgeLeft == edge) {
            f.origin.y = p.y;
        }
        else {
            f.origin.x = p.x;
        }
        v.frame = f;
		
        [UIView animateWithDuration:0.2
                         animations:^{
                             CGRect slideFrame = f;
                             slideFrame.origin = p;
                             v.frame = slideFrame;
                         }
                         completion: completion];
    }
    else {
        [UIView animateWithDuration:0.1f
                         animations:^{
                             v.frame = OffscreenFrameForSlideEdge(v, edge);
                         }
                         completion: ^(BOOL finished) {
                             [v removeFromSuperview];
                             if (completion) {
                                 completion(finished);
                             }
                         }];
	}
}

- (void) removeViewWithSlideX: (UIView*) v {
	[self removeViewWithSlideX: v fromScreenEdge: ScreenEdgeRight duration: 0.1f];
}

- (void) removeViewWithSlideX: (UIView*) v fromScreenEdge: (ScreenEdge) edge {
	[self removeViewWithSlideX: v fromScreenEdge: edge duration: 0.1f];
}

- (void) removeViewWithSlideX: (UIView*) v fromScreenEdge: (ScreenEdge) edge duration: (float) dur {
    [self removeViewWithSlide: v fromScreenEdge: edge duration: dur completion: nil];
}

- (void) removeViewWithSlide: (UIView*) v fromScreenEdge: (ScreenEdge) edge duration: (float) dur completion: (void(^)(BOOL finished)) completion {
    CGRect f = OffscreenFrameForSlideEdge(v, edge);
    [UIView animateWithDuration: dur animations: ^{ v.frame = f; } completion: ^(BOOL finished) {
        [v removeFromSuperview];
        completion(finished);
    }];
}

- (void) slideView: (UIView*) v fromScreenEdge: (ScreenEdge) edge {
	CGPoint p = v.frame.origin;
	if (![v superview]) {
        if (ScreenEdgeLeft == edge) {
            if (p.x < 0) {
                p.x = 0;
            }
        }
        else if (ScreenEdgeRight == edge) {
            if (p.x >= self.bounds.size.width) {
                p.x = self.bounds.size.width - v.frame.size.width;
            }
        }
        else if (ScreenEdgeTop == edge) {
            if (p.y < 0) {
                p.y = 0;
            }
        }
        else if (ScreenEdgeBottom == edge) {
            if (p.y >= self.bounds.size.height) {
                p.y = self.bounds.size.height - v.frame.size.height;
            }
        }
    }
	
	[self slideView: v toPoint: p fromScreenEdge: edge];
}

const int MENU_VIEW_MARGIN = 10;
- (void) slideView: (UIView*) v nextTo: (UIView*) target fromScreenEdge: (ScreenEdge) edge {
	int targetY = 0;
	CGRect tf = target.frame;
	if ([target superview] != self) {
		tf = [self convertRect: tf fromView: [target superview]];
		targetY = tf.origin.y;
	}
	float tx = CGRectGetMaxX(tf);
	// slide to whichever side has room
	if (self.bounds.size.width - tx < v.bounds.size.width) {
		tx = tf.origin.x - v.bounds.size.width;
	}
	
	tf.origin.y -= (v.bounds.size.height - tf.size.height) / 2;
	if (tf.origin.y < MENU_VIEW_MARGIN) {
		tf.origin.y = MENU_VIEW_MARGIN;
	}
	else if (tf.origin.y + v.frame.size.height > self.bounds.size.height - MENU_VIEW_MARGIN) {
        tf.origin.y = self.bounds.size.height - v.frame.size.height - MENU_VIEW_MARGIN;
    }
    
	if (![v superview]) {
		if (ScreenEdgeLeft == edge || ScreenEdgeRight == edge) {
			[v setFrameOrigin: CGPointMake(0, tf.origin.y)];
		}
		else {
			[v setFrameOrigin: CGPointMake(tf.origin.x, 0)];
		}
	}
	
	if ([v respondsToSelector: @selector(setArrowY:)]) {
		[(id)v setArrowY: targetY + target.frame.size.height/2 - tf.origin.y];
	}
	NSLog(@"sliding to point: %2.f, %2.f", tx,tf.origin.y);
	[self slideView: v toPoint: CGPointMake(tx, tf.origin.y) fromScreenEdge: edge];
}

- (void)slideFinishedSoRemove:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[(__bridge UIView*)context removeFromSuperview];
}

static const float pulsesteps[3] = { 0.2f, 1/15.f, 1/7.5f };

- (void) colorPulse {
	UIColor* c = [self backgroundColor];
	self.backgroundColor = [UIColor colorWithRed:0.8f green:0.8f blue:1.0f alpha:1.0f];
	[UIView beginAnimations:nil context: nil];
	[UIView setAnimationDuration: 0.3];
	self.backgroundColor = c;
	[UIView commitAnimations];
}

- (void) pulse {
	[self pulseWithScale: 1.f];
}

- (void) pulseWithScale: (float) scale {
	self.transform = CGAffineTransformMakeScale(0.6, 0.6);
    
    [UIView animateWithDuration: pulsesteps[0]
                     animations: ^{
                         self.transform = CGAffineTransformMakeScale(1 + .1f * scale, 1 + .1f * scale);
                     }
                     completion: ^(BOOL fin) {
                         [UIView animateWithDuration: pulsesteps[1]
                                          animations: ^{
                                              self.transform = CGAffineTransformMakeScale(1 - scale * 0.1, 1 - scale * 0.1);
                                          }
                                          completion: ^(BOOL fin) {
                                              [UIView animateWithDuration: pulsesteps[2]
                                                               animations: ^{
                                                                   self.transform = CGAffineTransformIdentity;
                                                               } completion: nil];
                                          }];
                     }];
}

- (void) startShadowPulsing {
    CABasicAnimation *ba = [CABasicAnimation animationWithKeyPath: @"shadowRadius"];
    ba.fromValue = @(0.f);
    ba.toValue = @(16.f);
    ba.repeatCount  = 100000;
    ba.autoreverses = YES;
    ba.duration = 0.5f;
    self.layer.shadowOpacity = 1.f;
    self.layer.shadowOffset = CGSizeZero;
    [self.layer addAnimation: ba forKey: @"shadowRadius"];
}

- (void) stopShadowPulsing {
    [self.layer removeAnimationForKey: @"shadowRadius"];
    self.layer.shadowOpacity = 0.f;
}

- (void) shake {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.1];
    [animation setRepeatCount:4];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake(self.center.x - 8.0f, self.center.y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake(self.center.x + 8.0f, self.center.y)]];
    [self.layer addAnimation:animation forKey:@"position"];
}

- (void) fillRoundedBounds:(UIColor*) color {
	[self fillRoundedBounds: color borderColor: color];
}

- (void) fillRoundedBounds:(UIColor*) color borderColor: (UIColor*) bColor {
	[self fillRoundedBounds: color borderColor: bColor borderWidth: RoundedEdgeStrokeWidth cornerRadius: RoundedCornerRadius];
}

- (void) fillRoundedBounds:(UIColor*) color borderColor: (UIColor*) bColor borderWidth: (float)width cornerRadius: (float)radius {
	CGRect r = self.bounds;
	r.size.height -= width;
	r.size.width -= width;
	r.origin.x += width / 2;
	r.origin.y += width / 2;
	ISFillRoundedRect(UIGraphicsGetCurrentContext(), r, radius, color, bColor, width);
}

- (void) disableMultitouch {
    Class c = [UIControl class];
    for (UIView* v in self.subviews) {
        if ([v isKindOfClass: c]) {
            v.exclusiveTouch = TRUE;
        }
    }
}

- (UIView*) busyView {
    return (UIView*)objc_getAssociatedObject(self, &kBusyView);
}

static int kBusyView = 9457;
- (void) showBusyView: (BOOL) withActivityIndicator {
    NSLog(@"showBusyView");
    __block UIView* v = (UIView*)objc_getAssociatedObject(self, &kBusyView);
    void (^addBusyView)() = ^{
        UIActivityIndicatorView* vb = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        vb.tag = kBusyView;
        [v addSubview: vb];
        vb.center = v.center;
        [vb startAnimating];
        vb.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    };
    
    if (!v) {
        v = [[UIView alloc] initWithFrame: self.bounds];
        v.backgroundColor = [ColorFromRGB(0) colorWithAlphaComponent: 0.5];
        v.opaque = FALSE;
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview: v];
        objc_setAssociatedObject(self, &kBusyView, v, OBJC_ASSOCIATION_ASSIGN);
        if (withActivityIndicator) {
            addBusyView();
        }
    }
    else {
        UIView* vb = [v viewWithTag: kBusyView];
        if (withActivityIndicator){
            if (!vb) {
                addBusyView();
            }
        }
        else {
            if (vb) {
                [vb removeFromSuperview];
            }
        }
    }
}

- (void) showBusyView {
    [self showBusyView: TRUE];
}

- (void) hideBusyView {
    UIView* v = (UIView*)objc_getAssociatedObject(self, &kBusyView);
    if (v) {
        [v removeWithFade];
        objc_setAssociatedObject(self, &kBusyView, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void) showDisabledView {
    [self showBusyView: FALSE];
}

- (void) hideDisabledView {
    [self hideBusyView];
}

@end


float deg2rad(float d) {
    return d * ((float)M_PI / 180.f);
}

void ISDrawPieAngle(CGContextRef c, CGRect rect, int d0, int d1, UIColor* sliceColor, UIColor* pieColor) {
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat radius = midx - rect.origin.x;
    if (pieColor) {
        CGContextSetFillColorWithColor(c, [pieColor CGColor]);
        CGContextMoveToPoint(c, midx, midy);
        CGContextAddArc(c, midx, midy, radius, deg2rad(270 + d0), deg2rad(270 + d1), 0);
        CGContextClosePath(c);
        CGContextFillPath(c);
    }
    if (sliceColor) {
        CGContextSetFillColorWithColor(c, [sliceColor CGColor]);
        CGContextMoveToPoint(c, midx, midy);
        CGContextAddArc(c, midx, midy, radius, deg2rad(270 + d0), deg2rad(270 + d1), 1);
        CGContextClosePath(c);
        CGContextFillPath(c);
    }
}

const float RoundedEdgeStrokeWidth = 2.0f;
const float RoundedCornerRadius = 10.0f;
void ISRoundedRectPath(CGContextRef c, CGRect rect, float radius) {
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
	
	CGContextMoveToPoint(c, minx, midy);
	CGContextAddArcToPoint(c, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(c, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(c, minx, maxy, minx, midy, radius);
	CGContextClosePath(c);
}

void ISStrokeRoundedRect(CGContextRef c, CGRect rect, float radius, UIColor* color) {
	CGContextSetLineWidth(c, RoundedEdgeStrokeWidth);
	CGContextSetStrokeColorWithColor(c, [color CGColor]);
	ISRoundedRectPath(c, rect, radius);
	CGContextDrawPath(c, kCGPathStroke);
}

void ISFillRoundedRect(CGContextRef c, CGRect rect, float radius, UIColor* fill, UIColor* border, float borderWidth) {
	if (!border) {
        border = fill;
    }
    if (borderWidth < 0.01) {
        borderWidth = RoundedEdgeStrokeWidth;
    }
    //CGContextSetAllowsAntialiasing(c, true);
	CGContextSetLineWidth(c, borderWidth);
	CGContextSetFillColorWithColor(c, [fill CGColor]);
	CGContextSetStrokeColorWithColor(c, [border CGColor]);
	ISRoundedRectPath(c, rect, radius);
	CGContextDrawPath(c, kCGPathFillStroke);
}

void ISClipRoundedRect(CGContextRef c, CGRect rect, float radius) {
	ISRoundedRectPath(c, rect, radius);
    CGContextClip(c);
}

void ISDrawRetinaLine(CGContextRef c, CGRect r, UIColor* color) {
    if (IS_RETINA) {
        r.origin.y += 0.5;
    }
    else {
        color = [color colorWithAlphaComponent: 0.5];
    }
    [color setFill];
    CGContextFillRect(c, r);
}
