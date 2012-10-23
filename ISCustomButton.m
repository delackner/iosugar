#import "ISCustomButton.h"

#import <QuartzCore/QuartzCore.h>

@implementation CustomButton

@synthesize titleLabel;

- (UILabel*) makeTitleLabel {
    return [[UILabel alloc] initWithFrame: CGRectMake(0,0,320,21)];
}

- (id) initWithButton: (UIButton*) b {
    if (nil != (self = [super initWithFrame: b.frame])) {
        self.opaque = FALSE;
        self.tag = b.tag;
        CALayer* hl = [CALayer layer];
        hl.actions = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"hidden"];
        hl.backgroundColor = [[[UIColor blackColor] colorWithAlphaComponent: 0.5] CGColor];
        hl.frame = self.bounds;
        [self.layer addSublayer: hl];
        hl.hidden = TRUE;
        hiLayer = hl;
        
        self.backgroundColor = [UIColor clearColor];
		image = [b imageForState: UIControlStateNormal];
		selImage = [b imageForState: UIControlStateSelected];
		actions = [NSMutableDictionary dictionary];
		target = [[b allTargets] anyObject];
        UIControlEvents events = [b allControlEvents];
        for (UIControlEvents e = UIControlEventTouchDown; e <= UIControlEventTouchCancel; e = e << 1) {
            if (0 != (events & e)) {
                NSArray* someActions = [b actionsForTarget: target forControlEvent: e];
                if (someActions) {
                    [actions setObject: someActions forKey: N(e)];
                }
            }
        }
        UILabel* tmpLabel = [self makeTitleLabel];
        titleLabel = tmpLabel;
        titleLabel.frame = b.titleLabel.frame;
        titleLabel.opaque = b.titleLabel.opaque;
        titleLabel.font = b.titleLabel.font;
        titleLabel.textColor = b.titleLabel.textColor;
        titleLabel.backgroundColor = b.titleLabel.backgroundColor;
        if (!titleLabel.backgroundColor) {
            titleLabel.backgroundColor = [UIColor clearColor];
        }
        [self addSubview: titleLabel];
    }
    return self;
}

+ (id) replaceButton: (UIControl*) b {
    CustomButton* c = [[CustomButton alloc] initWithButton: (UIButton*)b];
    if (c) {
		[[b superview] addSubview: c];
		[b removeFromSuperview];
    }
	return c;
}

- (BOOL) triggeredState: (UIControlEvents) e {
    BOOL triggered = FALSE;
    for (NSString* s in [actions objectForKey: N(e)]) {
        triggered = TRUE;
        SEL sel = NSSelectorFromString(s);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector: sel withObject: self];
#pragma clang diagnostic pop
    }
    return triggered;
}

- (void) setHighlighted:(BOOL)hi {
    [super setHighlighted: hi];
    hiLayer.hidden = !hi;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.highlighted = TRUE;
    [self triggeredState: UIControlEventTouchDown];
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.highlighted = FALSE;
	UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView: self.superview];
    [self triggeredState: CGRectContainsPoint(self.frame,p) ? UIControlEventTouchUpInside : UIControlEventTouchUpOutside];
	[self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	self.highlighted = FALSE;
    [self triggeredState: UIControlEventTouchCancel];
	[self setNeedsDisplay];
}

#pragma clang diagnostic pop

- (void) drawRect: (CGRect) r {
	CGRect f = self.bounds;
	UIImage* img = self.selected ? selImage : image;
	if (img) {
        CGRect imgFrame = CGRectMake(0,0,img.size.width, img.size.height);
        [img drawInRect: CenterRectInRect(imgFrame, f)];
	}
}

@end


UIControl* ReplaceWithGlowButton(UIControl* c) {
    GlowButton* g = [[GlowButton alloc] initAndReplaceButton: (UIButton*)c];
    return g;
}

@implementation GlowButton

- (id) initAndReplaceButton: (UIButton*) b {
	if (nil != (self = [super initWithFrame: b.frame])) {
		self.opaque = FALSE;
		self.backgroundColor = [UIColor clearColor];
		image = [b imageForState: UIControlStateNormal];
		selImage = [b imageForState: UIControlStateSelected];
		actions = [NSMutableDictionary dictionary];
		target = [[b allTargets] anyObject];
        UIControlEvents events = [b allControlEvents];
        for (UIControlEvents e = UIControlEventTouchDown; e <= UIControlEventTouchCancel; e = e << 1) {
            if (0 != (events & e)) {
                NSArray* someActions = [b actionsForTarget: target forControlEvent: e];
                if (someActions) {
                    [actions setObject: someActions forKey: N(e)];
                }
            }
        }
        
		[[b superview] addSubview: self];
		[b removeFromSuperview];
        
        CALayer* gl = [CALayer layer];
        gl.actions = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"hidden"];
        UIImage* img = [UIImage loadImage: @"buttonGlow"];
        gl.contents = (__bridge id)[img CGImage];
        gl.frame = self.bounds;
        [self.layer addSublayer: gl];
        gl.hidden = TRUE;
        glowLayer = gl;
    }
	return self;
}

- (BOOL) triggeredState: (UIControlEvents) e {
    BOOL triggered = FALSE;
    for (NSString* s in [actions objectForKey: N(e)]) {
        triggered = TRUE;
        SEL sel = NSSelectorFromString(s);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector: sel withObject: self];
#pragma clang diagnostic pop
    }
    return triggered;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.highlighted = TRUE;
    glowLayer.hidden = FALSE;
    [self triggeredState: UIControlEventTouchDown];
	[self setNeedsDisplay];
}

- (void) onEnd {
	self.highlighted = FALSE;
    glowLayer.hidden = TRUE;
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self onEnd];
	UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView: self.superview];
    [self triggeredState: CGRectContainsPoint(self.frame,p) ? UIControlEventTouchUpInside : UIControlEventTouchUpOutside];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self onEnd];
    [self triggeredState: UIControlEventTouchCancel];
}

#pragma clang diagnostic pop

- (void) drawRect: (CGRect) r {
	CGRect f = self.bounds;
	UIImage* img = self.selected ? selImage : image;
	if (!img) {
		[self fillRoundedBounds: [UIColor grayColor]];
	}
	else {
        CGRect imgFrame = CGRectMake(0,0,img.size.width, img.size.height);
        [img drawInRect: CenterRectInRect(imgFrame, f)];
        if (!self.enabled) {
            [[UIColor colorWithWhite:0 alpha:0.5] setFill];
            CGContextFillRect(UIGraphicsGetCurrentContext(), r);
        }
	}
}

- (void) dealloc {
    NSLog(@"glowbuttonboom");
}

@end

@implementation DoubleButton
@synthesize image, selImage, hiImage, background;

- (id) initAndReplaceButton: (UIButton*) b {
	if (nil != (self = [super initWithFrame: b.frame])) {
		self.opaque = FALSE;
		self.backgroundColor = [UIColor clearColor];
		self.image = [b imageForState: UIControlStateNormal];
		self.selImage = [b imageForState: UIControlStateSelected];
		self.hiImage = [b imageForState: UIControlStateHighlighted];
		self.background = [b backgroundImageForState: UIControlStateNormal];
		
		target = [[b allTargets] anyObject];
		if (!target) {
			NSLog(@"no target specified for DoubleButton %p", self);
		}
        
		NSString* s1 = [[b actionsForTarget: target forControlEvent: UIControlEventTouchUpInside] lastObject];
		NSString* s2 = [[b actionsForTarget: target forControlEvent: UIControlEventTouchDownRepeat] lastObject];
		
        //		if (!s1) {
        //			NSLog(@"no single tap action for doubleButton %p", self);
        //		}
        //		if (!s2) {
        //			NSLog(@"no double tap action for doubleButton %p", self);
        //		}
		
		//	[self addTarget:self action:@selector(evalTouch:forEvent:) forControlEvents:UIControlEventTouchDown];
		
		selSingle = NSSelectorFromString(s1);
		selDouble = NSSelectorFromString(s2);
        
		[[b superview] addSubview: self];
		[b removeFromSuperview];
	}
	return self;
}

- (void) setImage: (UIImage*) img {
	image = img;
    [self setNeedsDisplay];
}

- (void) setHiImage: (UIImage*) img {
	hiImage = img;
    [self setNeedsDisplay];
}

- (void) setSelImage: (UIImage*) img {
	selImage = img;
    [self setNeedsDisplay];
}

- (void) setImage: (UIImage*) img forState: (UIControlState) s {
	if (UIControlStateNormal == s) {
		self.image = img;
	}
	else if (UIControlStateHighlighted == s) {
		self.hiImage = img;
	}
	else if (UIControlStateSelected == s) {
		self.selImage = img;
	}
	else {
		NSLog(@"DoubleButton does not support images for control state %d", s);
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.highlighted = TRUE;
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = [touch tapCount];
	
	if (selDouble && 2 == tapCount) {
		[NSObject cancelPreviousPerformRequestsWithTarget:target selector:selSingle object: self];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[target performSelector:selDouble withObject: self];
#pragma clang diagnostic pop
	}
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.highlighted = FALSE;
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = [touch tapCount];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	if (!selDouble) {
		[target performSelector:selSingle withObject: self];
    }
    else if (tapCount < 2) {
		[target performSelector:selSingle withObject: self afterDelay:0.15];
	}
#pragma clang diagnostic pop
	[self setNeedsDisplay];
}


- (void) drawRect: (CGRect) r {
	CGRect f = self.bounds;
	UIImage* img = self.image;
    
	if (self.highlighted) {
		if (self.hiImage) {
			img = self.hiImage;
		}
	}
	else if (self.selected) {
		if (self.selImage) {
			img = self.selImage;
		}
	}
	
	if (!img && !background) {
		[self fillRoundedBounds: [UIColor grayColor]];
	}
	else {
		if (background) {
			[background drawInRect:f];
		}
		if (img) {
            CGRect imgFrame = CGRectMake(0,0,img.size.width, img.size.height);
			[img drawInRect: CenterRectInRect(imgFrame, f)];
		}
	}
	
	if ((self.highlighted || self.selected) && img == self.image) {
		[[UIColor colorWithWhite:0.f alpha:0.4f] set];
		CGContextFillRect(UIGraphicsGetCurrentContext(), f);
		//	[self fillRoundedBounds: [UIColor colorWithRed:47/255.f green:117/255.f blue:217/255.f alpha:0.5f]];
	}
}

@end

@implementation LongHoldButton

- (void) setSelected: (BOOL) s {
	[super setSelected: s];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.highlighted = TRUE;
	scheduled = TRUE;
    touch = [touches anyObject];
    CGPoint p = [touch locationInView: self];
    touchStartX = p.x;
    touchStartY = p.y;
	[self performSelector:@selector(runSingle) withObject: nil afterDelay: 0.2f];	// !!!
}

- (BOOL) movedTooFar {
    BOOL moved = FALSE;
    if (touch) {
        CGPoint point = [touch locationInView:self];
        CGPoint p0 = CGPointMake(touchStartX, touchStartY);
        //NSLog(@"dist: %d", Distance(p0, point));
        if (Distance(p0, point) > 10) {
            moved = TRUE;
        }
    }
    return moved;
}

- (void) runSingle {
	scheduled = FALSE;
    if (![self movedTooFar]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:selDouble withObject:self];
#pragma clang diagnostic pop
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.highlighted = FALSE;
	if (scheduled) {
		scheduled = FALSE;
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runSingle) object: nil];
        if (![self movedTooFar]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selSingle withObject: self];
#pragma clang diagnostic pop
        }
    }
    touch = nil;
}

@end