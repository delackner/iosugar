#import "IOSugar.h"

@interface GrowlView : UIView
@end

typedef void (^VoidCallbackBlock) (id context);
@interface Growler : UIViewController {
    BOOL ending;
	u8 choice;
	int updateIndex;
	id delegate;
	SEL didEndSelector;
	SEL actions[3];
	id context;
	
	IBOutlet UILabel* tTitle;
	IBOutlet UITextView* tMessage;
	IBOutlet UIButton* b0;
	IBOutlet UIButton* b1;
	IBOutlet UIButton* b2;
	IBOutlet UIView* coreView;
	IBOutlet UIActivityIndicatorView* busyView;
	IBOutlet UIProgressView* progressView;
	NSArray* buttons;
}
@property (nonatomic) u8 choice;
@property (nonatomic) BOOL disablePulse;
@property (nonatomic, strong) UIView* coreView;
@property (nonatomic, strong) UIActivityIndicatorView* busyView;
@property (nonatomic, strong) UIProgressView* progressView;
@property (nonatomic, strong) UILabel* tTitle;
@property (nonatomic, strong) IBOutlet UITextView *tMessage;
@property (nonatomic, strong) UIButton* b0;
@property (nonatomic, strong) UIButton* b1;
@property (nonatomic, strong) UIButton* b2;
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic) SEL didEndSelector;
@property (nonatomic, strong) id context;
@property (nonatomic, copy) void (^handler) (int);

- (void) dismiss;

+ (Growler*) currentGrowler;
+ (void) setGrowlEnabled: (BOOL) e;
+ (Growler*) growlerWithTitle: (NSString*) title message:(NSString*) message;
- (void) setButton0:(NSString*)s target: (id) target action: (SEL) action;
- (void) setButton1:(NSString*)s target: (id) target action: (SEL) action;
- (void) setButton2:(NSString*)s target: (id) target action: (SEL) action;
- (void) showWithViewController: (UIViewController*) vc;

@end

@interface UIViewController(Growl)

- (Growler*) growl:(NSString*) title message:(NSString*) message;
- (Growler*) growl:(NSString *)title message:(NSString *)message closeButton: (NSString*) closeTitle;

- (Growler*) growl:(NSString *)title message:(NSString *)message then: (void (^)(void))handler;
- (Growler*) growl:(NSString *)title message:(NSString *)message okButton: (NSString*) okTitle ok: (void (^)(int result)) handler;

// caller should implement a method like -(void) growlDidEndSelector: (Growler*) growler;  and access the growler.choice property. choice == index of button that was pressed
- (Growler*) growl:(NSString *)title message:(NSString *)message buttonTitle: (NSString*) bTitle action: (SEL) s;
- (Growler*) growl:(NSString *)title message:(NSString *)message endSelector: (SEL) endSel b0: (NSString*) title0 b1: (NSString*) title1 b2: (NSString*) title2 ;

- (Growler*) growl:(NSString *)title message:(NSString *)message
				b0: (NSString*) title0 t0: (id) t0 a0: (SEL) a0
				b1: (NSString*) title1 t1: (id) t1 a1: (SEL) a1
				b2: (NSString*) title2 t2: (id) t2 a2: (SEL) a2
;

- (void) growlBusy:(NSString*) title message:(NSString*) message; // cannot cancel
- (void) growlWaiting:(NSString*) title message:(NSString*) message; // has cancel button

- (Growler*) growlProgress:(NSString*) title endSelector:(SEL) s;
- (void) updateProgress: (NSNumber*) p;

- (void) growlEnd ;
- (void) growlEndNow ;
@end
