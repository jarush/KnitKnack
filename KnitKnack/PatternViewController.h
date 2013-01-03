//
//  PatternViewController.h
//  KnitKnack
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatternView.h"

@interface PatternViewController : UIViewController

@property (nonatomic, retain) PatternView *patternView;

- (id)initWithImage:(UIImage *)image;

@end
