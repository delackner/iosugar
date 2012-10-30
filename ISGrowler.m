#import "ISGrowler.h"

#define GROWL_DISMISS_SECONDS 1.9

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
	g.handler = ^(int ignored){
        onOK();
    };
    [g setButton1:LS(@"OK") target:nil action:@selector(pressed0:)];
	[g showWithViewController: self];
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
    float f = [p floatValue];
    DBLog(@"%2.f complete", f);
    growler.progressView.progress = f;
}

- (void) growlEnd {
	if (growler) {
		[growler dismiss];
	}
}

- (void) growlEndNow {
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

@synthesize coreView, busyView, progressView, tTitle, tMessage, didEndSelector, context, b0, b1, b2, choice, handler;

- (BOOL)canBecomeFirstResponder {
    return TRUE;
}

- (id) delegate { return delegate; }

- (void) setDelegate: (id) d {
	delegate = d;
	//CGRect f = tMessage.frame;
	//tMessage.frame = f;
}

+ (Growler*) growlerWithTitle: (NSString*) title message:(NSString*) message {
	if (growler) {
		[growler dismiss];
	}
	growler = [[Growler alloc] initWithTitle: title message: message];
	return growler;
}

- (id) initWithTitle:(NSString*) title message: (NSString*) message {
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
        
		self.tTitle.text = title;
		self.tMessage.text = message;
		CGRect f = self.coreView.frame;
		CGRect tf = self.tMessage.frame;
		CGSize maxSize = CGSizeMake(f.size.width, tf.size.height * 20);
		CGSize sz = [message sizeWithFont: tMessage.font constrainedToSize: maxSize lineBreakMode: UILineBreakModeWordWrap];
		if (sz.height > tf.size.height) {
			float diff = sz.height - tf.size.height;
			f.size.height += diff;
			tf.size.height += diff;
			coreView.frame = f;
			tMessage.frame = tf;
			
			f = busyView.frame;
			f.origin.y = CGRectGetMaxY(tf) + 8;
			busyView.frame = f;
		}
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
    self.view.frame = vc.view.bounds;
	[vc.view addSubviewWithFade: self.view];
	[[self coreView] pulse];
    [self performSelector:@selector(willAppear) withObject:nil afterDelay:0.1];
}

- (void) willAppear {
    if (self.view.superview) {
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

@end

@implementation GrowlView
- (void) awakeFromNib {
	[self setBackgroundColor: [UIColor clearColor]];
	self.opaque = FALSE;
	//self.alpha = 0.7;
}
- (void) drawRect:(CGRect) r {
	//[super drawRect: r];
	[[UIImage imageNamed:@"growl.png"] drawInRect: self.bounds];
}
@end