//  IOSugar.h
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

#ifndef IOSUGAR_H
#define IOSUGAR_H

#define LS(x) [[NSBundle mainBundle] localizedStringForKey:(x) value:@"" table:nil]
#define N(x) [NSNumber numberWithInt: x]
#define F(x) [NSNumber numberWithDouble: x]

// necessary evil for ARRAY(...)
#define IDARRAY(...) ((__autoreleasing id[]){ __VA_ARGS__ })
#define IDCOUNT(...) (sizeof(IDARRAY(__VA_ARGS__)) / sizeof(id))
// The non-macro version is provided because if you put an entire ^block in ARRAY(), you can't set breakpoints inside.
NSArray *array(id items, ...);
#define ARRAY(...) ([NSArray arrayWithObjects: IDARRAY(__VA_ARGS__) count: IDCOUNT(__VA_ARGS__)])

#if DEBUG
    #define DBLog(args...) DBLog_(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
    #define NSLog(args...) DBLog(args);
#else
#define DBLog(...)
#endif

typedef id(^Block_id_id)(id);

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long u32;
typedef unsigned long long u64;

typedef signed char s8;
typedef signed short int s16;
typedef signed long s32;
typedef signed long long s64;

#import "ISDebug.h"
#import "NSArray+Sugar.h"
#import "NSString+Sugar.h"

#import "UIButton+Sugar.h"
#import "UIControl+Sugar.h"
#import "UIImage+Sugar.h"
#import "UIView+Sugar.h"

#import "ISBatchDownloader.h"
#ifdef IOSUGAR_WITH_REQUEST_POOL
#import "ISUniqueRequestPool.h"
#endif
#import "ISCustomButton.h"
#import "ISGrowler.h"

#ifdef __cplusplus
extern "C" {
#endif
	
void DBLog_(const char *file, int line, const char *func, NSString *fmt,...);
NSUInteger random_below(NSUInteger n);
double Distance(CGPoint p1, CGPoint p2);
CGRect CenterRectInRect(CGRect inner, CGRect outer);
CGPoint CenterSizeInRect(CGSize inner, CGRect outer);
CGRect CenterRectOverPoint(CGRect r, CGPoint p);

BOOL WriteDictionaryBinary(id d, NSString* path);

#define SIGNDIFF(x,y) ((x < 0 && y > 0) || (x > 0 && y < 0))

UIColor* ColorFromRGB(int rgbValue);

u8 BitCount(u32 x);

#ifdef __cplusplus
}
#endif

#ifdef _COREDATADEFINES_H
#define MOC_NEW(moc, name) ((name*) [moc insertNew: @#name])
@interface NSManagedObjectContext (Sugar)
- (NSArray*) fetch:(NSString *)name;
- (NSArray*) fetch:(NSString *)entityName withPredicate:(id)stringOrPredicate, ... ;
- (NSArray*) fetch:(NSString *)name sortKey: (NSString*) sortKey ascending: (BOOL) asc predicate:(id)stringOrPredicate, ...;

- (id) insertNew: (NSString*) entityName;
@end
#endif

@interface NSUserDefaults (Sugar)
- (void) setKey: (NSString*) key bytes: (void*) bytes length: (int) sz;
- (void) setIntegerIfGreater:(NSInteger)value forKey:(NSString *)key;
@end

@interface UIActionSheet(ISAnimation)
- (void) showInView: (UIView*) v for:(NSTimeInterval) seconds;
- (void) dismissWithDelay: (NSTimeInterval) delay;
- (void) dismiss:(id)ignored;
@end

DEFH(SegueNotification); //posted on segueToVC and popMultiple.

@interface UIViewController(Sugar)
- (UIViewController*) showViewFromNib:(NSString*) className ;
- (UIViewController*) showViewFromNibWithFlip:(NSString*) className ;
- (UIViewController*) showViewFromNibWithFade:(NSString*) className ;
- (UIViewController*) showViewFromNibWithCurlUp:(NSString*) className ;

// navigation-based transitions
- (UIViewController*) pushViewFromNibWithFade: (NSString*) className ;
- (void) popWithFade;
- (void) popMultiple:(int) n;
- (void) popReplacingParentVC: (UIViewController*) newParent;
- (void) popToVC: (UIViewController*) parent;

- (void) pushVC: (UIViewController*) vc withSlideFromEdge: (ScreenEdge) edge;
- (void) popWithSlideToEdge: (ScreenEdge) edge;
- (void) willPop;
- (void) setBackButton: (NSString*) title action: (SEL) action;
- (UIViewController*) segueTo: (NSString*) className;
- (BOOL) segueShouldFade;
- (void) segueToVC: (UIViewController*) vc;
- (void) segueToVC: (UIViewController*) vc animated: (BOOL) animated;
- (UIViewController*) fadeToSubviewController: (NSString*) className;
@end

#define AllocProp(prop, ...) { id allocProp_temp_ = __VA_ARGS__; self . prop = allocProp_temp_; [allocProp_temp_ release]; }



@interface ISNavigationController: UINavigationController
@end

@interface UINavigationController(Sugar)
- (UIViewController*) pushView: (NSString*) nibName;
@end

@interface RoundedView : UIView {
    UIColor* fillColor;
    UIColor* borderColor;
	float borderWidth;
	float cornerRadius;
}
@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic, strong) UIColor* borderColor;
@property (nonatomic) float borderWidth;
@property (nonatomic) float cornerRadius;

@end

@interface PieView: UIView

@property (nonatomic) int d0;
@property (nonatomic) int d1;

@property (nonatomic, strong) UIColor* sliceColor;
@property (nonatomic, strong) UIColor* pieColor;
@end

@interface MenuView: UIView {
	CGPoint arrowOrigin;
	BOOL loaded;
	BOOL arrowOnRight;
}
@property (nonatomic, assign) BOOL arrowOnRight;

- (void) setArrowY: (float) y;
@end

@interface UILabel(Sugar)
+ (UILabel*) labelFittingText: (NSString*) text font: (UIFont*) font;
+ (UILabel*) labelFittingText: (NSString*) text font: (UIFont*) font numberOfLines: (int) max;
- (void) setTextAnimated: (NSString*) t withColor: (UIColor*) c;
- (UIView*) addHighlightView: (UIColor*) c;
@end

@interface NSObject (Cleanup)

- (void) releaseProperties;
- (void) releasePropertiesAndViews;
@end

#pragma mark LazyMenu

@class LazyMenu;
typedef LazyMenu* (^BlockLazyMenu_Array)(NSArray* path);
typedef void (^BlockVoid_Cell)(UITableViewCell* cell);

@interface LazyMenu : NSObject
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSArray* menus;
@property (nonatomic, strong) BlockLazyMenu_Array action;
@property (nonatomic, strong) BlockVoid_Cell formatter;

+ (LazyMenu*) menuWithTitle: (NSString*) title menus: (NSArray*) menus formatter: (BlockVoid_Cell) formatter action: (BlockLazyMenu_Array) action;
@end

//LazyMenu* Menu(NSString* title, NSArray* menus, BlockArray_Array action);
//LazyMenu* MenuWithFormatter(NSString* title, NSArray* menus, BlockArray_Array action, BlockVoid_Cell formatter);

@interface RoundedLabel: UILabel

@property (nonatomic, strong) UIColor* bgColor;
@property (nonatomic) int cornerRadius;
@end

#ifdef __cplusplus
extern "C" {
#endif
    
extern BOOL IS_RETINA;
BOOL OSVersionAtLeast(NSString* want);
BOOL OSVersionAtLeast4(void);
BOOL OSVersionAtLeast5(void);
BOOL IsAACHardwareEncoderAvailable(void) ;
uint64_t FreeSpace();
NSString* DeviceModelName(void);

extern NSUserDefaults* DEF;
    
#pragma mark GCD sugar
    
extern void dispatch_main_after(double delayInSeconds, dispatch_block_t block);
extern void performBlockOnMainThread(dispatch_block_t block);
    
#ifdef __cplusplus
} //C
#endif
        
#endif //H
