//
//  PatternViewController.m
//  KnitKnack
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "PatternViewController.h"

@implementation PatternViewController

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.title = @"Pattern";
        
        _patternView = [[PatternView alloc] initWithFrame:CGRectZero image:image];

        UIPinchGestureRecognizer *pinchGestureRecgonizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(handlePinch:)] autorelease];
        [_patternView addGestureRecognizer:pinchGestureRecgonizer];

        self.view = _patternView;
    }
    return self;
}

- (void)dealloc {
    [_patternView release];
    [super dealloc];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float scale = gestureRecognizer.scale;
    CGPoint point = [gestureRecognizer locationInView:_patternView];

    NSLog(@"pinch - point: (%f, %f)  scale: %f", point.x, point.y, scale);
}

@end
