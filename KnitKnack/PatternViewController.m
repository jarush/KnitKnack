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
        self.view = _patternView;

        UISegmentedControl *segControl = [[[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 90, 30)] autorelease];
        segControl.momentary = YES;
        segControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [segControl insertSegmentWithTitle:@"\u25B2" atIndex:0 animated:NO];
        [segControl insertSegmentWithTitle:@"\u25BC" atIndex:1 animated:NO];
        [segControl addTarget:self action:@selector(segButtonDown:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segControl];
    }
    return self;
}

- (void)dealloc {
    [_patternView release];
    [super dealloc];
}

- (void)segButtonDown:(id)sender {
    UISegmentedControl *segControl = (UISegmentedControl *)sender;
    switch (segControl.selectedSegmentIndex) {
        case 0:
            [_patternView moveUp];
            break;
        case 1:
            [_patternView moveDown];
            break;
        default:
            break;
    }
}

@end
