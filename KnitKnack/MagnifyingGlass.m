//
//  MagnifyingGlass.m
//  KnitKnack
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "MagnifyingGlass.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_RADIUS 40.0f
#define DEFAULT_OFFSET -40.0f
#define DEFAULT_SCALE  1.5f

@implementation MagnifyingGlass

- (id)init {
    return [self initWithFrame:CGRectMake(0, 0, DEFAULT_RADIUS * 2, DEFAULT_RADIUS * 2)];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
		self.layer.borderWidth = 3;
		self.layer.cornerRadius = frame.size.width / 2;
		self.layer.masksToBounds = YES;

		_touchPointOffset = CGPointMake(0, DEFAULT_OFFSET);
		_scale = DEFAULT_SCALE;
		_viewToMagnify = nil;
		_scaleAtTouchPoint = YES;
	}
	return self;
}

- (void)dealloc {
    [_viewToMagnify release];
    [super dealloc];
}

- (void)setFrame:(CGRect)f {
	super.frame = f;
	self.layer.cornerRadius = f.size.width / 2;
}

- (void)setTouchPoint:(CGPoint)point {
    _touchPoint = [_viewToMagnify convertPoint:point toView:self.superview];
	self.center = CGPointMake(_touchPoint.x + _touchPointOffset.x, _touchPoint.y + _touchPointOffset.y);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
	CGContextScaleCTM(context, _scale, _scale);

    CGPoint magnifiedPoint = [_viewToMagnify convertPoint:_touchPoint fromView:self.superview];
	CGContextTranslateCTM(context, -magnifiedPoint.x, -magnifiedPoint.y + (_scaleAtTouchPoint ? 0 : self.bounds.size.height / 2.0f));

	[_viewToMagnify.layer renderInContext:context];
}

@end
