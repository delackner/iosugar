//  UIView+Sugar.h
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

typedef enum {
	ScreenEdgeLeft,
	ScreenEdgeRight,
	ScreenEdgeTop,
	ScreenEdgeBottom,
    ScreenEdgeNone
} ScreenEdge;

@interface UIView (Sugar)
- (void) setFrameOrigin: (CGPoint) p ;
- (void) setFrameX: (int) x;
- (void) setFrameY: (int) y;
- (void) setFrameW: (int) w;
- (void) setFrameH: (int) h;
- (void) snapToCenterX;

- (void) saveFrame;
- (void) loadFrame;
- (void) replaceWithFade: (UIView*) v ;
- (UIViewController*) replaceWithViewFromNib: (NSString*) className;
- (void) addSubviewWithFade: (UIView*) v;
- (void) addSubviewWithFade: (UIView*) v delegate: (id) d endSelector: (SEL) s context: (id) context;

- (void) removeWithFade;
- (void) removeWithFadeDuration:(NSTimeInterval) secs;

- (void) addSubviewWithFlip: (UIView*) v;
- (void) removeWithFlip;

- (void) addSubviewWithLocalFlip: (UIView*) v;
- (void) removeWithLocalFlip;

- (void) addSubviewWithCurlUp: (UIView*) v;
- (void) removeWithCurlDown;

- (void) slideView: (UIView*) v toPoint: (CGPoint) p fromScreenEdge: (ScreenEdge) d;
- (void) slideView: (UIView*) v toPoint: (CGPoint) p;
- (void) slideView: (UIView*) v fromScreenEdge: (ScreenEdge) edge;
- (void) slideView: (UIView*) v nextTo: (UIView*) target fromScreenEdge: (ScreenEdge) edge;
- (void) slideView: (UIView*) v toPoint: (CGPoint) p fromUnderView: (UIView*) cover;

- (void) slideView: (UIView*) v toPoint: (CGPoint) p fromScreenEdge: (ScreenEdge) edge completion: (void(^)(BOOL finished))completion;
- (void) removeViewWithSlide: (UIView*) v fromScreenEdge: (ScreenEdge) edge duration: (float) dur completion: (void(^)(BOOL finished)) completion;


- (void) removeViewWithSlideX: (UIView*) v;
- (void) removeViewWithSlideX: (UIView*) v fromScreenEdge: (ScreenEdge) edge;
- (void) removeViewWithSlideX: (UIView*) v fromScreenEdge: (ScreenEdge) edge duration: (float) dur;

- (void) pulse;
- (void) pulseWithScale: (float) scale;
- (void) colorPulse;
- (void) shake;

- (void) startShadowPulsing ;
- (void) stopShadowPulsing ;

- (void) fillRoundedBounds:(UIColor*) color;
- (void) fillRoundedBounds:(UIColor*) color borderColor: (UIColor*) borderColor;
- (void) fillRoundedBounds:(UIColor*) color borderColor: (UIColor*) borderColor borderWidth: (float)width cornerRadius: (float)radius;
- (UIImage*) asImage;

- (void) disableMultitouch;

- (UIView*) busyView;
- (void) showBusyView;
- (void) hideBusyView;
- (void) showDisabledView;
- (void) hideDisabledView;
@end

#ifdef __cplusplus
extern "C" {
#endif
    extern const float RoundedEdgeStrokeWidth;
    extern const float RoundedCornerRadius;

    float deg2rad(float d);
    void ISRoundedRectPath(CGContextRef c, CGRect rect, float radius);
    void ISClipRoundedRect(CGContextRef c, CGRect rect, float radius);
    void ISDrawPieAngle(CGContextRef c, CGRect rect, int d0, int d1, UIColor* pieColor, UIColor* sliceColor);
    void ISStrokeRoundedRect(CGContextRef c, CGRect rect, float radius, UIColor* color);
    void ISFillRoundedRect(CGContextRef c, CGRect rect, float radius, UIColor* fill, UIColor* border, float borderWidth);
    void ISDrawRetinaLine(CGContextRef c, CGRect r, UIColor* color);

#ifdef __cplusplus
}
#endif
