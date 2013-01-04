//
//  MagnifyingGlass.h
//  KnitKnack
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagnifyingGlass : UIView

@property (nonatomic, retain) UIView *viewToMagnify;
@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, assign) CGPoint touchPointOffset;
@property (nonatomic, assign) CGFloat scale; 
@property (nonatomic, assign) BOOL scaleAtTouchPoint; 

@end
