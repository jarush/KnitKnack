//
//  SelectionViewController.m
//  KnitKnack
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "SelectionViewController.h"
#import "PatternViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation SelectionViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"KnitKnack";

        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                                target:self
                                                                                                action:@selector(handleSelectImage:)] autorelease];
    }
    return self;
}

- (void)handleSelectImage:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.mediaTypes = @[(id)kUTTypeImage];
        imagePickerController.delegate = self;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
            [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        } else {
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];

    UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    if (image == nil) {
        NSLog(@"Image selected is nil");
        return;
    }

    PatternViewController *patternViewController = [[[PatternViewController alloc] initWithImage:image] autorelease];
    [self.navigationController pushViewController:patternViewController animated:YES];
}

@end
