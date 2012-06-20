//
//  UIControl+Sugar.m
//
//  Created by Seth Delackner on 9/12/12.
//
//

#import "UIControl+Sugar.h"

@implementation UIControl (Sugar)

- (void) setAction: (SEL) s {
	[self setTarget: [[self allTargets] anyObject] action: s];
}

- (void) setTarget: (id) t action: (SEL) a {
	for (id oldTarget in [self allTargets]) {
		[self removeTarget: oldTarget action: nil forControlEvents: UIControlEventTouchUpInside];
	}
	[self addTarget:t action:a forControlEvents:UIControlEventTouchUpInside];
}

@end