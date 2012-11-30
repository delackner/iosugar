//  IOSugar.m
//
//  Created by Seth Delackner on 9/10/08.
//  Copyright (c) 2008 
//  All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//    * Neither the name of the <organization> nor the
//    names of its contributors may be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//    DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import <objc/runtime.h>
#import "IOSugar.h"

DEFS(SegueNotification);

static char navigationRetainKey;

BOOL IS_RETINA;
BOOL IsRetina();

@interface NSObject(IOSugarInit)
@end

@implementation NSObject(IOSugarInit)
+ (void) load {
    IS_RETINA = IsRetina();
}
@end

//private
BOOL IsRetina() {
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))?1:0;
}

CGRect OffscreenFrameForSlideEdge(UIView* v, ScreenEdge edge);

double Distance(CGPoint p1, CGPoint p2) {
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)); 
}

CGPoint CenterSizeInRect(CGSize inner, CGRect outer) {
	CGPoint p = CGPointMake(outer.origin.x + (outer.size.width - inner.width) / 2, outer.origin.y + (outer.size.height - inner.height) / 2);
	return p;
}

CGRect CenterRectOverPoint(CGRect r, CGPoint p) {
	r = CGRectMake(p.x - (r.size.width / 2), p.y - (r.size.height / 2), r.size.width, r.size.height);
	return r;
}

CGRect CenterRectInRect(CGRect inner, CGRect outer) {
	return CGRectMake(outer.origin.x + (outer.size.width - inner.size.width) / 2, outer.origin.y + (outer.size.height - inner.size.height) / 2, inner.size.width, inner.size.height);
}


u8 BitCount(u32 x) {
	x -= ((x >> 1) & 0x55555555);
    x = (x & 0x33333333) + ((x >> 2) & 0x33333333);
    x += (x >> 4);
    x &= 0x0f0f0f0f;
    x += (x >> 8);
    x += (x >> 16);
    return (u8)x;
}

UIColor* ColorFromRGB(int v) {
    UIColor* c = [UIColor colorWithRed:((float)((v & 0xFF0000) >> 16))/255.0 green:((float)((v & 0xFF00) >> 8))/255.0 blue:((float)(v & 0xFF))/255.0 alpha:1.0];
    return c;
}

NSUInteger random_below(NSUInteger n) {
    return random() % n;
}

BOOL WriteDictionaryBinary(id d, NSString* path) {
    BOOL ok = FALSE;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString* tmpPath = FMT(@"%@-tmp", path);
    [fm removeItemAtPath: tmpPath error: nil];
    NSOutputStream* s = [[NSOutputStream alloc] initToFileAtPath:tmpPath append:NO];
    [s open];
    [NSPropertyListSerialization writePropertyList:d toStream: s
                                                              format:NSPropertyListBinaryFormat_v1_0
                                                             options: 0
                                                               error:&error];
    [s close];
    if (error) {
        NSLog(@"error writing binary plist: %@", error);
        [fm removeItemAtPath:tmpPath error:nil];
    }
    else {
        NSString* bakPath = FMT(@"%@-bak", path);

        [fm removeItemAtPath: bakPath error:nil];
        [fm moveItemAtPath:path toPath: bakPath error:nil];
        [fm moveItemAtPath:tmpPath toPath:path error:&error];
        if (error) {
            NSLog(@"error writing binary plist (atomic move): %@", error);
            [fm moveItemAtPath: bakPath toPath: path error: nil];
            [fm removeItemAtPath: tmpPath error: nil];
        }
        else {
            [fm removeItemAtPath: bakPath error: nil];
            ok = TRUE;
        }
    }
    return ok;
}

@implementation NSUserDefaults (Suger)

+ (void) load {
    DEF = [NSUserDefaults standardUserDefaults];
}

- (void) setKey: (NSString*) key bytes: (void*) bytes length: (int) sz {
	id d = [NSData dataWithBytesNoCopy:bytes length:sz freeWhenDone:FALSE];
	[self setObject: d forKey: key];
}
@end

@implementation UIViewController(Sugar)

- (UIViewController*) showViewFromNib:(NSString*) className {
	return [self showViewFromNibWithFlip: className];
}

- (UIViewController*) showViewFromNibWithFlip:(NSString*) className {
    UIViewController* m = [[NSClassFromString(className) alloc] initWithNibName:className bundle:[NSBundle mainBundle]];
	[[self view] addSubviewWithFlip: [m view]];
	return m;
}

- (void) pushWithFade: (UIViewController*) vc {
    UIView* matrix = self.navigationController.view;
    UIImage* img = [matrix asImage];
    UIImageView* imageView = [[UIImageView alloc] initWithImage: img];
    imageView.frame = CGRectMake(0,0, img.size.width, img.size.height);

    [[self navigationController] pushViewController:vc animated:NO];
    [vc viewWillAppear: YES];
    imageView.alpha = 1;
    [matrix addSubview: imageView];
    
    [UIView animateWithDuration:0.2 animations:^{
        imageView.alpha = 0;
    }completion:^(BOOL fin) {
        [imageView removeFromSuperview];
        //NSLog(@"re-enabled user interaction for %@", self);
        self.view.userInteractionEnabled = TRUE;
    }];
}

- (UIViewController*) pushViewFromNibWithFade: (NSString*) className {
    UIViewController* vc = [[NSClassFromString(className) alloc] initWithNibName:className bundle:[NSBundle mainBundle]];
    [self pushWithFade: vc];
	return vc;    
}

- (void) popToVC: (UIViewController*) parent {
    UINavigationController* n = self.navigationController;
    NSEnumerator* e = [[n viewControllers] reverseObjectEnumerator];
    int i = 0;
    UIViewController* vc;
    while (nil != (vc = [e nextObject])) {
        if (vc == parent) {
            break;
        }
        i++;
    }

    if (i) {
        [self popMultiple: i];
    }
}

- (void) popMultiple:(int) mul {
    static BOOL popping = FALSE;
    if (popping) {
        return;
    }
    popping = TRUE;
    UINavigationController* n = self.navigationController;

    UIView* matrix = n.view;
    UIImage* img = [matrix asImage];
    UIImageView* imageView = [[UIImageView alloc] initWithImage: img];
    imageView.frame = CGRectMake(0,0, img.size.width, img.size.height);
    
    NSArray* a = [n viewControllers];
    UIViewController* prev = [a objectAtIndex: [a count] - (1 + mul)];

    if (0 == [a count] - (1 + mul)) {
        [self.navigationController setNavigationBarHidden: TRUE animated: TRUE];
    }
    else { 
        BOOL hide = ![prev.navigationItem leftBarButtonItem] && ![prev.navigationItem rightBarButtonItem];
        [self.navigationController setNavigationBarHidden:hide animated: YES];
    }
    
    int count = mul;
    if (!count) {
        count = 1;
    }
    for (int i = 0; i < count; i++) {
        UIViewController* vc = [n topViewController];
        [vc willPop];
        [n popViewControllerAnimated: NO];
    }

    [matrix addSubview: imageView];
    [UIView animateWithDuration: 0.2 animations: ^{
        imageView.alpha = 0;
    } completion: ^(BOOL fin) {
        [imageView removeFromSuperview];
    }];
    
    popping = FALSE;
}

- (void) willPop {
    
}

- (void) popWithFade {
    [self popMultiple: 1];
}

- (UIViewController*) fadeToSubviewController: (NSString*) className {
    UIViewController* vc = [[NSClassFromString(className) alloc] initWithNibName:className bundle:[NSBundle mainBundle]];
    if (vc) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SegueNotification object: vc];
        objc_setAssociatedObject(vc.view, &navigationRetainKey, vc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        vc.view.alpha = 0;
        [self.view addSubview: vc.view];
        
        [UIView animateWithDuration:0.2 animations:^{
            vc.view.alpha = 1;
        }completion:nil];
    }
    else {
        NSLog(@"failed fadeToSubviewController: %@", className);
    }
    return vc;
}

- (UIViewController*) segueTo: (NSString*) className {
    UIViewController* vc = [[NSClassFromString(className) alloc] initWithNibName:className bundle:[NSBundle mainBundle]];
    if (vc) {
        [self segueToVC: vc];
    }
    else {
        NSLog(@"Failed segue: couldnt load %@", className);
    }
    return vc;
}

- (UIViewController*) prepareVCForPush: (UIViewController*) vc {
    return [self prepareVCForPush: vc animated: YES];
}

- (UIViewController*) prepareVCForPush: (UIViewController*) vc animated: (BOOL) anim {
    if (anim && !self.view.userInteractionEnabled) {
        NSLog(@"ignoring segue while user interaction disabled.  maybe we are already seguing?");
        return nil;
    }
    NSLog(@"%@ segueTo: %@", self, vc);
    self.view.userInteractionEnabled = FALSE;
    objc_setAssociatedObject(vc.view, &navigationRetainKey, vc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([vc.navigationItem leftBarButtonItem] || [vc.navigationItem rightBarButtonItem]) {
        [self.navigationController setNavigationBarHidden:NO animated: YES];
    }
    return vc;
}

- (void) segueToVC: (UIViewController*) vc animated: (BOOL) animated {
    if (vc) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SegueNotification object: vc];
        [self prepareVCForPush: vc animated: animated];
        if (!animated) {
            [self.navigationController pushViewController:vc animated:NO];
            self.view.userInteractionEnabled = TRUE;
        }
        else {
            [self pushWithFade: vc];
        }
    }
}

- (void) segueToVC: (UIViewController*) vc {
    [self segueToVC: vc animated: YES];
}

- (void) pushVC: (UIViewController*) vc withSlideFromEdge: (ScreenEdge) edge {
    if (vc) {
        vc = [self prepareVCForPush: vc];
        if (vc) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SegueNotification object: vc];
            [self.view slideView:vc.view toPoint:CGPointZero fromScreenEdge:edge completion:^(BOOL finished){
                [vc.view removeFromSuperview];
                [[self navigationController] pushViewController:vc animated:NO];
                [vc viewWillAppear: YES];
                //NSLog(@"re-enabled user interaction for %@", self);
                self.view.userInteractionEnabled = TRUE;        
            }];
        }
    }
}

- (void) popWithSlideToEdge: (ScreenEdge) edge {
    UINavigationController* n = self.navigationController;
    NSArray* a = [n viewControllers];
    if (0 == [a count] - 2) {
        [n setNavigationBarHidden: TRUE animated: TRUE];
    }
    UIViewController* prev = [a objectAtIndex: [a count] - 2];
    UIImage* img = [[prev view] asImage];
    UIImageView* imageView = [[UIImageView alloc] initWithImage: img];
    imageView.frame = CGRectMake(0,0, img.size.width, img.size.height);
    [self.view.superview insertSubview: imageView belowSubview: self.view];
    [self.view removeViewWithSlide:self.view fromScreenEdge:edge duration:0.2 completion: ^(BOOL finished) 
     {
         [imageView removeFromSuperview];
         [n popViewControllerAnimated: NO];
                     }];
}

-(void) pushVC_:(NSString *)animationID finished:(NSNumber *) finished context:(void *)context 
{    
    UIViewController* vc = (__bridge UIViewController*)context;
    [[self navigationController] pushViewController:vc animated:NO];
    [vc viewWillAppear: YES];
    //NSLog(@"re-enabled user interaction for %@", self);
    self.view.userInteractionEnabled = TRUE;
}

- (UIViewController*) showViewFromNibWithFade:(NSString*) className {
    UIViewController* m = [[NSClassFromString(className) alloc] initWithNibName:className bundle:[NSBundle mainBundle]];
	[[self view] addSubviewWithFade: [m view]];
	return m;
}

- (UIViewController*) showViewFromNibWithCurlUp:(NSString*) className {
    UIViewController* m = [[NSClassFromString(className) alloc] initWithNibName:className bundle:[NSBundle mainBundle]];
	[[self view] addSubviewWithCurlUp: [m view]];
	return m;
}

- (void) setBackButton: (NSString*) title action: (SEL) action {
    UIImage *buttonImage = [UIImage imageNamed:@"NavBack.png"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    aButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    UIBarButtonItem* aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    [aButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [aButton setTitle: title];
    self.navigationItem.leftBarButtonItem = aBarButtonItem;
}

@end

#import <objc/runtime.h>
#import <objc/message.h>
@implementation NSObject (Cleanup)

- (void) releaseProperties {
	unsigned int n;
	Class c = [self class];
	//DBLog(@"%@ clearing props", c);
	
	objc_property_t* properties = class_copyPropertyList(c, &n);
	const char* attr;
	for (unsigned int i = 0; i < n; i++) {
		objc_property_t property = properties[i];
		NSString* name = [NSString stringWithCString:property_getName(property) encoding: NSUTF8StringEncoding];
		attr = property_getAttributes(property);
		if (strstr(attr,"T@")) {
			//DBLog(@"\t prop %@, properties:%s", name, property_getAttributes(property));
			[self setValue: nil forKey: name];
		}
	}
	free(properties);
}

- (void) releasePropertiesAndViews {
    NSLog(@"UNSUPPORTED");
}

@end

@implementation UIActionSheet(ISAnimation)
- (void) showInView: (UIView*) v for:(NSTimeInterval) seconds {
	[self showInView: v];
	[self dismissWithDelay: seconds];
}

- (void) dismissWithDelay: (NSTimeInterval) delay {
	[self performSelector:@selector(dismiss:) withObject:self afterDelay:1];
}
- (void) dismiss:(id)ignored {
	[self dismissWithClickedButtonIndex: 0 animated: YES];
}
@end

@implementation ISNavigationController
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController* vc = [super popViewControllerAnimated: animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:SegueNotification object: vc];
    objc_setAssociatedObject(vc.view, &navigationRetainKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return vc;
}
@end



@implementation UINavigationController(Sugar)
- (UIViewController*) pushView: (NSString*) nibName {
	UIViewController* vc = [[NSClassFromString(nibName) alloc] initWithNibName: nil bundle: nil];
	[self pushViewController: vc animated: YES];
	return vc;
}
@end


@implementation UILabel(Sugar)
+ (UILabel*) labelFittingText: (NSString*) text font: (UIFont*) font {
	return [UILabel labelFittingText: text font: font numberOfLines: 1];
}

- (UIView*) addHighlightView: (UIColor*) c {
    UILineBreakMode mode = 1 == self.numberOfLines ? UILineBreakModeTailTruncation : UILineBreakModeWordWrap ;
	CGSize sz = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode: mode];
    CGRect f = CGRectInset(CGRectMake(CGRectGetMaxX(self.frame) - sz.width, self.frame.origin.y, sz.width, sz.height), -8, -4);
    
    RoundedView* v = [[RoundedView alloc] initWithFrame: f];
    v.backgroundColor = c;
    [self.superview insertSubview:v belowSubview:self];
    return v;
}

- (void) setTextAnimated: (NSString*) t withColor: (UIColor*) c {
    self.text = t;
    UIView* v = [self addHighlightView: c];
    self.text = @"";
    v.alpha = 0.f;
    [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationCurveEaseIn animations:^(){ [self setText: t]; v.alpha = 1.f; }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0 options: UIViewAnimationCurveEaseOut animations:^(){ v.alpha = 0.f; }
                                          completion:^(BOOL finished) {
                                              [v removeFromSuperview];
                                          }];
                     }];
}

+ (UILabel*) labelFittingText: (NSString*) text font: (UIFont*) font numberOfLines: (int) max {
	UILineBreakMode mode = 0 == max ? UILineBreakModeWordWrap : UILineBreakModeTailTruncation;
	CGSize textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode: mode];
	UILabel* label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, textSize.width, textSize.height)];
	label.numberOfLines = max;
	label.font = font;
	label.text = text;
	return label;
}

@end

@implementation RoundedView

@synthesize fillColor;
@synthesize borderColor;
@synthesize borderWidth;
@synthesize cornerRadius;

- (void)willMoveToSuperview:(UIView *)newSuperview {
    self.fillColor = [self backgroundColor];
    self.borderColor = [UIColor clearColor];//[self backgroundColor];
    if (newSuperview) {
		[self setOpaque: NO];
        [self setBackgroundColor: [UIColor clearColor]];//[newSuperview backgroundColor]];
    }
}

- (void) setCornerRadius:(float)cr {
    cornerRadius = cr;
    [self setNeedsDisplay];
}

- (void) drawRect: (CGRect) r {
	if (!borderWidth)	borderWidth = RoundedEdgeStrokeWidth;
	if (!cornerRadius)	cornerRadius = RoundedCornerRadius;
    [self fillRoundedBounds: fillColor borderColor: borderColor borderWidth: borderWidth cornerRadius: cornerRadius];
    [super drawRect: r];
}

- (void) dealloc {
    fillColor = nil;
    borderColor = nil;
}
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch* t = [touches anyObject];
	CGPoint p = [t locationInView: self];
	NSLog(@"began: %d %d", p.x, p.y);
	[super touchesBegan: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch* t = [touches anyObject];
	CGPoint p = [t locationInView: self];
	NSLog(@"moved: %d %d", p.x, p.y);
	[super touchesMoved: touches withEvent: event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch* t = [touches anyObject];
	CGPoint p = [t locationInView: self];
	NSLog(@"ended: %d %d", p.x, p.y);
	[super touchesEnded: touches withEvent: event];
}*/


@end

@implementation PieView

- (void) awakeFromNib {
    self.sliceColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
}

- (void) setD0:(int)d0 {
    _d0 = d0;
    [self setNeedsDisplay];
}

- (void) setD1:(int)d1 {
    _d1 = d1;
    [self setNeedsDisplay];
}

- (void) drawRect: (CGRect) r {
    CGContextRef c = UIGraphicsGetCurrentContext();
    ISDrawPieAngle(c, r, _d0, _d1, self.pieColor, self.sliceColor);
}

@end

@implementation MenuView 
@synthesize arrowOnRight;

- (void) setArrowY: (float) y {
	UIImage* img = [UIImage imageNamed: @"smallBrowserBalloon.png"];
	arrowOrigin.y = y - (img.size.height)/2;
}

- (void) setArrowOnRight: (BOOL) onRight {
	UIView* v = [[self subviews] lastObject];
	if (!loaded || arrowOnRight != onRight) {
		loaded = TRUE;
		arrowOnRight = onRight;
		CGRect vf = v.frame;
		vf.origin.x = onRight ? 0 : CGRectGetMaxX(self.frame) - vf.size.width ;
		v.frame = vf;
		
		UIImage* img = [UIImage imageNamed: @"smallBrowserBalloon.png"];
		arrowOrigin.x = onRight ? CGRectGetMaxX(vf) - 1 : vf.origin.x - img.size.width + 1;
		arrowOrigin.y = (self.bounds.size.height - img.size.height)/2;
		
		[self setNeedsDisplay];
	}
}

- (void) drawRect: (CGRect) r {
	UIImage* img = [UIImage imageNamed: @"smallBrowserBalloon.png"];
	if (arrowOnRight) {
		[img drawHorizontallyFlippedAtPoint:arrowOrigin context: UIGraphicsGetCurrentContext() alpha:0.85f];
	}
	else {
		[img drawAtPoint:arrowOrigin blendMode:kCGBlendModeNormal alpha:0.85f];
	}
	[super drawRect: r];
}

#pragma mark Add to Beta

NSString* MakeWindowsSafeFilename(NSString* title) {
	NSString* ret = nil;
	int len = [title length];
	if (len) {
		NSMutableString* filename = [[NSMutableString alloc] init];
		NSCharacterSet* badSet = [NSCharacterSet characterSetWithCharactersInString: @"<>:\"/\\|?*\r\n\t"];
		unichar c;
		for (int i = 0; i < len; i++) {
			c = [title characterAtIndex: i];
			if ('.' != c || i < len - 1) {
				if (![badSet characterIsMember: c]) {
					[filename appendFormat: @"%c", c];
				}
			}
		}
		if ([filename length]) {
			NSCharacterSet* whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
			while ([whiteSpace characterIsMember: [filename characterAtIndex: [filename length] - 1]]) {
				[filename deleteCharactersInRange: NSMakeRange([filename length] - 1, 1)];
			}
			ret = [filename copy];
		}
	}
	return ret;
}

BOOL OSVersionAtLeast(NSString* reqSysVer) {
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	return [currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending;
}

BOOL OSVersionAtLeast4(void){
    static BOOL initialized = FALSE;
    static BOOL atLeast = FALSE;
    if (!initialized) {
        initialized = TRUE;
        atLeast = OSVersionAtLeast(@"4");
    }
    return atLeast;
}

BOOL OSVersionAtLeast5(void){
    static BOOL initialized = FALSE;
    static BOOL atLeast = FALSE;
    if (!initialized) {
        initialized = TRUE;
        atLeast = OSVersionAtLeast(@"5");
    }
    return atLeast;
}

@end

@implementation LazyMenu

@synthesize title;
@synthesize menus;
@synthesize action;
@synthesize formatter;

+ (LazyMenu*) menuWithTitle: (NSString*) title menus: (NSArray*) menus formatter: (BlockVoid_Cell) formatter action: (BlockLazyMenu_Array) action {
    LazyMenu* m = [LazyMenu new];
    m.title = title;
    m.menus = menus;
    m.formatter = formatter;
    m.action = action;
    return m;
}

@end

@implementation RoundedLabel
@synthesize bgColor, cornerRadius;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    bgColor = self.backgroundColor;
    cornerRadius = 3;
    self.backgroundColor = [UIColor clearColor];
    return self;
}

- (void) setBackgroundColor:(UIColor *)bg {
    if (![bg isEqual: [UIColor clearColor]]) {
        [super setBackgroundColor: [UIColor clearColor]];
        [self setBgColor: bg];
    }
}

- (void) setCornerRadius:(int)cr {
    cornerRadius = cr;
    [self setNeedsDisplay];
}

- (void) drawRect: (CGRect) r {
    ISFillRoundedRect(UIGraphicsGetCurrentContext(), CGRectInset(r, 1, 1), cornerRadius, bgColor, 0, 0);
    [super drawRect: r];
}

- (void) sizeToFit {
    [super sizeToFit];
	CGSize textSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) lineBreakMode: self.lineBreakMode];
    textSize.width += 8;
    CGRect f = self.frame;
    f.size = textSize;
    self.frame = f;
}

@end

BOOL IsAACHardwareEncoderAvailable(void) {
    static BOOL loaded=FALSE;
    static BOOL isAvailable = FALSE;
    if (!loaded) {
        loaded = TRUE;
        OSStatus error;
        
        UInt32 encoderSpecifier = kAudioFormatMPEG4AAC;
        UInt32 size;
        
        error = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders, sizeof(encoderSpecifier),
                                           &encoderSpecifier, &size);
        if (error) { printf("AudioFormatGetPropertyInfo kAudioFormatProperty_Encoders error %lu %4.4s\n", error, (char*)&error); return FALSE; }
        
        UInt32 numEncoders = size / sizeof(AudioClassDescription);
        AudioClassDescription encoderDescriptions[numEncoders];
        
        error = AudioFormatGetProperty(kAudioFormatProperty_Encoders, sizeof(encoderSpecifier),
                                       &encoderSpecifier, &size, encoderDescriptions);
        if (error) { printf("AudioFormatGetProperty kAudioFormatProperty_Encoders error %lu %4.4s\n",
                            error, (char*)&error); return FALSE; }
        
        for (UInt32 i=0; i < numEncoders; ++i) {
            if (encoderDescriptions[i].mSubType == kAudioFormatMPEG4AAC &&
                encoderDescriptions[i].mManufacturer == kAppleHardwareAudioCodecManufacturer) 
            {
                isAvailable = TRUE;
                break;
            }
        }
    }
    
    return isAvailable;
}

uint64_t FreeSpace() {
    //uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];  
    
    if (dictionary) {  
        //NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        //totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        //NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {  
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %d", [error domain], [error code]);  
    }  
    
    return totalFreeSpace;
}

NSString* DeviceModelName(void) {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);     
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    free(name);    
    return machine;
}

void dispatch_main_after(double delayInSeconds, dispatch_block_t block) {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

void performBlockOnMainThread(dispatch_block_t block) {
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
    else {
        block();
    }
}

NSUserDefaults* DEF;
