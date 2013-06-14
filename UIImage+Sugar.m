#import "UIImage+Sugar.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIImage (Sugar)

+ (UIImage*)loadImage:(NSString*)aFilename {
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", bundlePath,aFilename]];
}

- (void) drawCentered: (CGPoint) p {
	[self drawCentered: p alpha: 1.f];
}

- (void) drawCentered: (CGPoint) p alpha: (float) a {
	CGSize sz = self.size;
	CGPoint center = CGPointMake(p.x - (sz.width / 2), p.y - (sz.height / 2));
	[self drawAtPoint:center blendMode:kCGBlendModeNormal alpha: a];
}

+ (UIImage*) buttonBackgroundNamed:(NSString*) name size: (CGSize) bgSize {
	UIImage* img = [UIImage imageNamed:name];
	return [img asButtonBackgroundOfSize: bgSize];
}

- (UIImage*)asButtonBackgroundOfSize: (CGSize) bgSize{
	static const int cap = 11;
    if (!OSVersionAtLeast4()) {
        return self;
    }
	UIImage* img = self;
	//NSLog(@"baseImage %p", img);
	UIImage* middle;
	CGContextRef ctxt;
	
	CGSize sz = CGSizeMake(1, img.size.height);
	UIGraphicsBeginImageContext(sz);
	ctxt = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(ctxt, 0, sz.height);
	CGContextConcatCTM(ctxt, CGAffineTransformMakeScale(1, -1));
    
	[img drawInRect:CGRectMake(-cap, 0, img.size.width, img.size.height)];
	middle = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	
	UIGraphicsBeginImageContext(bgSize);
	ctxt = UIGraphicsGetCurrentContext();
    
	CGContextSaveGState(ctxt);
	CGContextClipToRect(ctxt, CGRectMake(0, 0, cap - 2, bgSize.height));
	[img drawInRect:CGRectMake(0, 0, img.size.width, bgSize.height)];
	CGContextRestoreGState(ctxt);
    
	CGContextSaveGState(ctxt);
	CGContextClipToRect(ctxt, CGRectMake(bgSize.width - cap, 0, cap, bgSize.height));
	[img drawInRect:CGRectMake(bgSize.width - img.size.width, 0, img.size.width, bgSize.height)];
	CGContextRestoreGState(ctxt);
    
	CGContextTranslateCTM(ctxt, 0, bgSize.height);
	CGContextConcatCTM(ctxt, CGAffineTransformMakeScale(1, -1));
    
	[middle drawInRect: CGRectMake(cap - 2, 0, bgSize.width - (2 * cap) + 2, bgSize.height)];
	UIImage* finalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return finalImage;
}

- (UIImage *) grayImage {
	CGSize sz = self.size;
	//CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
	CGRect rect = CGRectMake(0.0f, 0.0f, sz.width, sz.height);
	//NSLog([NSString stringWithFormat:@"width: %g",image.size.width]);
	//NSLog([NSString stringWithFormat:@"height: %g",image.size.height]);
	// Create a mono/gray color space
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(nil, sz.width, sz.height, 8, 0, colorSpace, kCGImageAlphaNone);
	
	//CGContextTranslateCTM(context, image.sz.width, 0);
	CGColorSpaceRelease(colorSpace);
	// Draw the image into the grayscale context
	CGContextDrawImage(context, rect, [self CGImage]);
	CGImageRef grayscale = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	// Recover the image
	UIImage *img = [UIImage imageWithCGImage: grayscale];
	CFRelease(grayscale);
	return img;
}

- (void) drawHorizontallyFlippedAtPoint: (CGPoint) p context: (CGContextRef) c {
	[self drawHorizontallyFlippedAtPoint:p context:c alpha: 1.f];
}

- (void) drawHorizontallyFlippedAtPoint: (CGPoint) p context: (CGContextRef) c alpha: (float) alpha {
    CGContextSaveGState(c);
	CGSize isz = self.size;
    CGContextTranslateCTM (c, p.x+isz.width, p.y) ;//isz.width, 0);
    CGContextScaleCTM (c, -1, 1);
	[self drawAtPoint: CGPointMake(0,0) blendMode: kCGBlendModeNormal alpha: alpha];
    //CGContextScaleCTM (c, -1, 1);
    //CGContextTranslateCTM (c, -isz.width, -isz.height);
    CGContextRestoreGState(c);
}


- (UIImage *)tintedWithColor:(UIColor *)theColor {
    return [self tintedWithColor: theColor blendMode: kCGBlendModeColorBurn scale: 1.0];
}

- (UIImage *)tintedWithColor:(UIColor *)theColor blendMode: (CGBlendMode) mode {
    return [self tintedWithColor: theColor blendMode: mode scale: 1.0];
}

- (UIImage *)tintedWithColor:(UIColor *)theColor blendMode: (CGBlendMode) mode scale: (float) scale {
	UIGraphicsBeginImageContextWithOptions(self.size, NO, scale); //TODO: hrm, scale 0.0 (auto) vs 1.0
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    // Flip the image
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextDrawImage(ctx, area, self.CGImage);
    CGContextSaveGState(ctx);

    CGContextClipToMask(ctx, area, self.CGImage);
    CGContextSetFillColorWithColor(ctx, theColor.CGColor);
    CGContextSetBlendMode(ctx, mode);
    
    CGContextFillRect(ctx, area);
    CGContextRestoreGState(ctx);
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*) imageWithBadge: (UIImage*) badge {
    return [self imageWithBadge: badge dimmed: 1.f];
}

- (UIImage*) imageWithBadge: (UIImage*) badge dimmed: (float) dimmed {
    UIImage* bottomImage = self;
    UIImage* topImage = badge;
    UIImageView* imageView = [[UIImageView alloc] initWithImage:bottomImage];
    UIImageView* subView   = [[UIImageView alloc] initWithImage:topImage];
    CGRect f = CGRectMake(bottomImage.size.width - topImage.size.width - 4, 4, topImage.size.width, topImage.size.height) ;
    [imageView addSubview:subView];
    [subView setFrame: f];
    UIGraphicsBeginImageContext(imageView.frame.size);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    if (dimmed < 1.f) {
        [[UIColor colorWithWhite:0.f alpha:dimmed] setFill];
        f.origin = CGPointZero;
        f.size = imageView.frame.size;
        UIRectFillUsingBlendMode(f, kCGBlendModeDarken);
    }
    UIImage* blendedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return blendedImage;
}

- (UIImage *)crop:(CGRect)rect {
    
    //    CGFloat scale = [[UIScreen mainScreen] scale];
    //
    //    if (scale>1.0) {
    //        rect = CGRectMake(rect.origin.x*scale , rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
    //    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return result;
}

- (void) savePNG: (NSString*) path {
    [UIImagePNGRepresentation(self) writeToFile: path atomically: YES];
}

// from: https://gist.github.com/bstahlhood
+ (UIImage *)retinaImageNamed:(NSString *)imageName {
    //NSLog(@"Loading image named => %@", imageName);
    NSMutableString *imageNameMutable = [imageName mutableCopy];
    NSRange retinaAtSymbol = [imageName rangeOfString:@"@"];
    if (retinaAtSymbol.location != NSNotFound) {
        [imageNameMutable insertString:@"-568h" atIndex:retinaAtSymbol.location];
    } else {
        if (IS_WIDESCREEN) {
            NSRange dot = [imageName rangeOfString:@"."];
            if (dot.location != NSNotFound) {
                [imageNameMutable insertString:@"-568h@2x" atIndex:dot.location];
            } else {
                [imageNameMutable appendString:@"-568h@2x"];
            }
        }
    }
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:@"png"];
    if (imagePath) {
        return [UIImage imageNamed:imageNameMutable];
    } else {
        return [UIImage imageNamed:imageName];
    }
    return nil;
}

@end

