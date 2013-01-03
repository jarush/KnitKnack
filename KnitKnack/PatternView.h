//
//  PatternView.h
//  KnitKnack
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatternView : UIView

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIColor *shadowColor;
@property (nonatomic, retain) UIColor *barColor;
@property (nonatomic, retain) UIColor *highlightBarColor;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;

- (void)moveUp;
- (void)moveDown;

@end
