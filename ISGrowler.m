#import <QuartzCore/QuartzCore.h>
#import "ISGrowler.h"

#define GROWL_DISMISS_SECONDS 1.9

static BOOL growlEnabled = TRUE;
static Growler* growler = nil;

@interface Growler(Private)
- (void) showWithViewController: (UIViewController*) vc;
- (void) willAppear;
- (id) initWithTitle:(NSString*) title message: (NSString*) message ;
@end

@implementation UIViewController(Growl)
- (Growler*) growl:(NSString*) title message:(NSString*) message {
	Growler* g = [Growler growlerWithTitle: title message: message];
    if (0 == [title length]) {
        g.tMessage.font = g.tTitle.font;
    }
	[g showWithViewController: self];
	return g;
}

- (Growler*) growl:(NSString *)title message:(NSString *)message closeButton: (NSString*) closeTitle {
	Growler* g = [Growler growlerWithTitle: title message: message];
	[g setButton1:closeTitle target:nil action:@selector(pressed0:)];
	[g showWithViewController: self];
	return g;
}

- (Growler*) growl:(NSString *)title message:(NSString *)message buttonTitle: (NSString*) bTitle action: (SEL) s {
    return [self growl: title message: message endSelector: s b0: nil b1: bTitle b2: nil];
}

- (Growler*) growl:(NSString *)title message:(NSString *)message okButton: (NSString*) okTitle ok: (void (^)(int result))handler
{
	Growler* g = [Growler growlerWithTitle: title message: message];
	g.handler = handler;
    if (![okTitle isEqualToString: LS(@"Cancel")]) {
        [g setButton0:LS(@"Cancel") target:nil action:@selector(pressed0:)];
        [g setButton2:okTitle target:nil action:@selector(pressed1:)];
    }
    else {
        [g setButton1:LS(@"Cancel") target:nil action:@selector(pressed0:)];
    }
	[g showWithViewController: self];
	return g;
}

- (Growler*) growl:(NSString *)title message:(NSString *)message then: (void (^)(void))onOK {
	Growler* g = [Growler growlerWithTitle: title message: message];
    if (g) {
        g.handler = ^(int ignored){
            onOK();
        };
        [g setButton1:LS(@"OK") target:nil action:@selector(pressed0:)];
        [g showWithViewController: self];
    }
    else if (onOK) {
        onOK();
    }
	return g;
}

- (Growler*) growl:(NSString *)title message:(NSString *)message endSelector: (SEL) endSel b0: (NSString*) title0 b1: (NSString*) title1 b2: (NSString*) title2 {
	Growler* g = [Growler growlerWithTitle: title message: message];
	[g setButton0:title0 target:nil action:@selector(pressed0:)];
	[g setButton1:title1 target:nil action:@selector(pressed1:)];
	[g setButton2:title2 target:nil action:@selector(pressed2:)];
	[g showWithViewController: self];
	g.delegate = self;
	g.didEndSelector = endSel;
	return g;
}

- (Growler*) growl:(NSString *)title message:(NSString *)message
				b0: (NSString*) title0 t0: (id) t0 a0: (SEL) a0
				b1: (NSString*) title1 t1: (id) t1 a1: (SEL) a1
				b2: (NSString*) title2 t2: (id) t2 a2: (SEL) a2
{
	Growler* g = [Growler growlerWithTitle: title message: message];
	[g setButton0:title0 target:t0 action:a0];
	[g setButton1:title1 target:t1 action:a1];
	[g setButton2:title2 target:t2 action:a2];
	[g showWithViewController: self];
	return g;
}

- (void) growlBusy:(NSString*) title message:(NSString*) message {
	Growler* g = [self growl:title message: message];
	g.busyView.hidden = FALSE;
}

- (void) growlWaiting:(NSString*) title message:(NSString*) message {
	Growler* g = [self growl:title message:[message stringByAppendingString:@"\n "] closeButton: LS(@"Cancel")];
	g.busyView.hidden = FALSE;
}

- (Growler*) growlProgress:(NSString*) title endSelector:(SEL) s {
	Growler* g = [self growl:title message:@"" closeButton: LS(@"Cancel")];
    g.progressView.hidden = FALSE;
    g.delegate = self;
    g.didEndSelector = s;
    return g;
}

- (void) updateProgress: (NSNumber*) p {
    if (!growlEnabled) {
        return;
    }
    float f = [p floatValue];
    DBLog(@"%2.f complete", f);
    growler.progressView.progress = f;
}

- (void) growlEnd {
    if (!growlEnabled) {
        return;
    }

	if (growler) {
		[growler dismiss];
	}
}

- (void) growlEndNow {
    if (!growlEnabled) {
        return;
    }

    if (growler) {
        [growler.view removeFromSuperview];
        growler = nil;
    }
}

@end

@implementation Growler

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

@synthesize coreView, disablePulse, busyView, progressView, tTitle, tMessage, didEndSelector, context, b0, b1, b2, choice, handler;

- (BOOL)canBecomeFirstResponder {
    return TRUE;
}

- (id) delegate { return delegate; }

- (void) setDelegate: (id) d {
	delegate = d;
	//CGRect f = tMessage.frame;
	//tMessage.frame = f;
}

+ (void) setGrowlEnabled: (BOOL) e {
    growlEnabled = e;
}

+ (Growler*) currentGrowler {
    if (!growlEnabled) {
        return nil;
    }
    return growler;
}

+ (Growler*) growlerWithTitle: (NSString*) title message:(NSString*) message {
    if (!growlEnabled) {
        return nil;
    }
	if (growler) {
		[growler dismiss];
	}
	growler = [[Growler alloc] initWithTitle: title message: message];
	return growler;
}

- (id) initWithTitle:(NSString*) title message: (NSString*) message {
    if (!growlEnabled) {
        return nil;
    }
	if (nil != (self = [super initWithNibName: @"Growler" bundle: nil])) {
		[self view];
		buttons = [[NSArray alloc] initWithObjects: b0, b1, b2, nil];
		for (UIButton* b in buttons) {
			b.hidden = TRUE;
		}
		self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		//[self.view setBackgroundColor: [UIColor clearColor]];
		//[self.view setOpaque: FALSE];
		//[self.view setAlpha: 0.2];
		self.busyView.hidden = TRUE;

        if (!title.length) {
            self.tMessage.font = self.tTitle.font;
        }
        else if (!message.length) {
            message = title;
            title = @"";
            self.tMessage.font = self.tTitle.font;
        }
		self.tTitle.text = title;
		self.tMessage.text = message;        
	}
	return self;
}

- (void) dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget: self];
    delegate = nil;
    DBLog(@"dealloc growler %p.", self);
    buttons = nil;
    context = nil;
    tTitle = nil;
    tMessage = nil;
    b0 = nil;
    b1 = nil;
    b2 = nil;
    coreView = nil;
    busyView = nil;
    progressView = nil;
    handler = nil;
}

- (void) showWithViewController: (UIViewController*) vc {
    CGRect f = self.coreView.frame;
    CGRect tf = self.tMessage.frame;
    CGSize sz = tMessage.contentSize;
    if (sz.height > tf.size.height) {
        float diff = sz.height - tf.size.height;
        float avail = self.view.frame.size.height - f.size.height - (coreView.frame.size.height - CGRectGetMaxY(tMessage.frame));
        if (diff > avail) {
            diff = avail;
        }
        f.size.height += diff;
        tf.size.height += diff;
        coreView.frame = f;
        tMessage.frame = tf;
        
        f = busyView.frame;
        f.origin.y = CGRectGetMaxY(tf) + 8;
        busyView.frame = f;
    }

    self.view.frame = vc.view.bounds;
    self.coreView.center = self.view.center;
    self.coreView.haveButtons = !b0.hidden || !b1.hidden || !b2.hidden;
    if (IS_IPAD) {
        if (!b1.hidden && b0.hidden && b2.hidden) {
            [b1 setFrameX: 0];
            [b1 setFrameW: self.coreView.frame.size.width];
        }
    }
    [self performSelector:@selector(showDelayed:) withObject: vc afterDelay: 0.2];
}

- (void) showDelayed: (UIViewController*) vc {
    NSLog(@"showDelayed. ending? %d", ending);
    if (!ending) {
        [vc.view addSubviewWithFade: self.view];
        if (!self.disablePulse) {
            [[self coreView] pulse];
        }
        [self performSelector:@selector(willAppear) withObject:nil afterDelay:0.1];
    }
}

- (void) willAppear {
    if (self.view.superview) {
        [self.view.superview bringSubviewToFront: self.view];
        if (b0.hidden && b1.hidden && b2.hidden && busyView.hidden && progressView.hidden) {
            [self performSelector:@selector(dismiss) withObject:nil afterDelay: GROWL_DISMISS_SECONDS];
        }
    }
}

- (void) setButtonIndex: (int) i title:(NSString*)s target: (id) target action: (SEL) action {
	UIButton* b = [buttons objectAtIndex: i];
	if (s) {
		b.hidden = FALSE;
		[b setTitle:s scaleFrame: TRUE];
		if (!target) {
			target = self;
		}
		[b addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	}
	else {
		b.hidden = TRUE;
	}
}

- (void) setButton0:(NSString*)s target: (id) target action: (SEL) action {
	[self setButtonIndex: 0 title: s target: target action: action];
}

- (void) setButton1:(NSString*)s target: (id) target action: (SEL) action {
	[self setButtonIndex: 1 title: s target: target action: action];
}

- (void) setButton2:(NSString*)s target: (id) target action: (SEL) action {
	[self setButtonIndex: 2 title: s target: target action: action];
}

- (void) end {
    if (self.view.superview) {
        if (!ending) {
            ending = TRUE;
            __block Growler* gg = self;
            growler = nil;
            [UIView animateWithDuration:0.2 animations:^{
                gg.view.alpha = 0.f;
            } completion: ^(BOOL fin) {
                [gg.view removeFromSuperview];
            }];
        }
    }
    ending = TRUE;
}

- (void)fadeFinishedSoRemove:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if (self.view.superview) {
        [self.view removeFromSuperview];
    }
}

- (void) endWithResult: (int) r {
	if (handler) {
		self.choice = r;
        [self end];
		handler(r);
        return;
	}
	else if (delegate && (nil != didEndSelector)) {
		self.choice = r;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[delegate performSelector:didEndSelector withObject: self];
#pragma clang diagnostic pop
        
	}
	[self end];
}

- (IBAction) pressed0: (id) sender {
	[self endWithResult: 0];
}

- (IBAction) pressed1: (id) sender {
	[self endWithResult: 1];
}

- (IBAction) pressed2: (id) sender {
	[self endWithResult: 2];
}

- (void)dismiss {
	[self end];
}

- (void) tintWithColor: (UIColor*) c {
//    self.coreView.tintColor = c;
//    [self.coreView setNeedsDisplay];
    for (UIButton* b in buttons) {
        [b setTitleColor:c forState:0];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end

@implementation GrowlView
- (void) awakeFromNib {
	[self setBackgroundColor: ColorFromRGB(0xE6E6E6)];
	self.opaque = FALSE;
    self.layer.cornerRadius = 8.f;
    self.layer.masksToBounds = YES;
	self.alpha = 0.97;
}

- (void) drawRect:(CGRect) r {
	[super drawRect: r];
//    UIImage* top = [UIImage imageNamed: @"growl_top.png"];
//    UIImage* mid = [UIImage imageNamed: @"growl_middle.png"];
//    UIImage* bot = [UIImage imageNamed: @"growl_bottom.png"];
//    
//    UIColor* c = self.tintColor;
//    if (c) {
//        top = [top tintedWithColor: c];
//        mid = [mid tintedWithColor: c];
//        bot = [bot tintedWithColor: c];
//    }
    
    if (self.haveButtons) {
        CGRect f = self.bounds;
        //    [top drawInRect: CGRectMake(0,0,f.size.width, top.size.height)];
        //    [bot drawInRect: CGRectMake(0,f.size.height - bot.size.height, f.size.width, bot.size.height)];
        //    f.origin.y += top.size.height;
        //    f.size.height -= top.size.height + bot.size.height;
        //    [mid drawInRect: f];
        
        CGContextRef c = UIGraphicsGetCurrentContext();
        ISDrawRetinaLine(c, CGRectMake(0,f.size.height - (IS_IPAD ? 60 : 40), f.size.width, 1), ColorFromRGB(0xD0D0D0));
    }
}

- (void) setFrame: (CGRect) f {
    [super setFrame: f];
}

@end