//
//  UIControl+Sugar.h
//
//  Created by Seth Delackner on 9/12/12.
//
//

@interface UIControl(Sugar)

- (void) setAction: (SEL) s;
- (void) setTarget: (id) t action: (SEL) a;

@end