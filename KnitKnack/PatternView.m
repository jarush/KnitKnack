//
//  PatternView.m
//  KnitKnack
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "PatternView.h"

typedef NS_ENUM(NSInteger, PatternViewHandle) {
    PatternViewHandleNone,
    PatternViewHandle1,
    PatternViewHandle2,
};

@interface PatternView () {
    CGImageRef offscreenImage;
    CGFloat y1;
    CGFloat y2;
    PatternViewHandle editingHandle;
}

- (CGAffineTransform)computeTransform;
- (CGImageRef)createOffscreenImage;

- (CGRect)shadow1;
- (CGRect)handle1;
- (CGRect)shadow2;
- (CGRect)handle2;

@end

@implementation PatternView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image {
    self = [super initWithFrame:frame];
    if (self) {
        _image = [image retain];

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
        self.barColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        self.highlightBarColor = [UIColor colorWithRed:1.0f green:0.8f blue:0.3f alpha:0.8f];
        self.backgroundColor = [UIColor blackColor];

        y1 = 100.0f;
        y2 = 200.0f;
    }
    return self;
}

- (void)dealloc {
    [_image release];
    [_shadowColor release];
    [_barColor release];
    [_highlightBarColor release];
    [super dealloc];
}

- (void)layoutSubviews {
    // Compute a new offscreen image with the original image scaled and center
    offscreenImage = [self createOffscreenImage];
}

- (CGAffineTransform)computeTransform {
    CGSize boundingSize = self.bounds.size;
    CGSize imageSize = _image.size;

    // Compute an affine transform to center the image
    float sx = (boundingSize.width - 20) / imageSize.width;
    float sy = (boundingSize.height - 20) / imageSize.height;
    float scale = sx < sy ? sx : sy;
    float tx = (boundingSize.width - imageSize.width * scale) / 2.0f;
    float ty = (boundingSize.height - imageSize.height * scale) / 2.0f;

    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, tx, ty);
    transform = CGAffineTransformScale(transform, scale, scale);

    return transform;
}

- (CGImageRef)createOffscreenImage {
    CGRect boundsRect = self.bounds;
    float w = boundsRect.size.width;
    float h = boundsRect.size.height;

    // Create a bitmap context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, w * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);

    // Flip the context so 0,0 is the upper left
    CGContextTranslateCTM(context, 0, h);
    CGContextScaleCTM(context, 1.0, -1.0);

    // Fill the background
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, w, h));

    // Apply the affine transform
    CGContextConcatCTM(context, [self computeTransform]);

    // Draw the image
    CGRect imageRect = CGRectMake(0, 0, _image.size.width, _image.size.height);
    CGContextDrawImage(context, imageRect, _image.CGImage);

    // Create an image from the context
    CGImageRef cgImage = CGBitmapContextCreateImage(context);

    // Release the context
    CGContextRelease(context);

    return cgImage;
}

- (void)moveUp {
    CGFloat dy = y2 - y1;
    if (y1 - dy < 10) {
        return;
    }

    y2 = y1;
    y1 -= dy;

    [self setNeedsDisplay];
}

- (void)moveDown {
    CGFloat dy = y2 - y1;
    if (y2 + dy > self.bounds.size.height - 10) {
        return;
    }

    y1 = y2;
    y2 += dy;

    [self setNeedsDisplay];
}

- (CGRect)shadow1 {
    return CGRectMake(0, 0, self.bounds.size.width, y1);
}

- (CGRect)handle1 {
    return CGRectMake(0, y1 - 20, self.bounds.size.width, 40);
}

- (CGRect)shadow2 {
    return CGRectMake(0, y2, self.bounds.size.width, self.bounds.size.height - y2);
}

- (CGRect)handle2 {
    return CGRectMake(0, y2 - 20, self.bounds.size.width, 40);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];

    if (CGRectContainsPoint(self.handle1, point)) {
        editingHandle = PatternViewHandle1;
    } else if (CGRectContainsPoint(self.handle2, point)) {
        editingHandle = PatternViewHandle2;
    } else {
        editingHandle = PatternViewHandleNone;
    }

    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat h = self.bounds.size.height;
    CGFloat y = point.y;

    // Update the correct handle
    switch (editingHandle) {
        case PatternViewHandle1:
            if (y > 10 && y < y2 - 2) {
                y1 = y;
            }
            break;

        case PatternViewHandle2:
            if (y < h - 10 && y > y1 + 2) {
                y2 = y;
            }
            break;

        default:
            break;
    }

    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    editingHandle = PatternViewHandleNone;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect clipRect = CGContextGetClipBoundingBox(context);

    // Draw the offscreen image
    CGContextDrawImage(context, clipRect, offscreenImage);

    // Draw the shadows
    CGContextSetFillColorWithColor(context, self.shadowColor.CGColor);
    CGContextFillRect(context, [self shadow1]);
    CGContextFillRect(context, [self shadow2]);

    // Draw the shadow lines
    CGContextSetLineWidth(context, 4.0);

    // Draw handle 1
    UIColor *color = editingHandle == PatternViewHandle1 ? self.highlightBarColor : self.barColor;
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, 0, y1);
    CGContextAddLineToPoint(context, clipRect.size.width, y1);
    CGContextStrokePath(context);

    // Draw handle 2
    color = editingHandle == PatternViewHandle2 ? self.highlightBarColor : self.barColor;
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, 0, y2);
    CGContextAddLineToPoint(context, clipRect.size.width, y2);
    CGContextStrokePath(context);
}

@end
