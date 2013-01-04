//
//  SelectionViewController.m
//  KnitKnack
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "SelectionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>

@interface SelectionViewController () {
    UIImageView *imageView;
    UILabel *label;
    UIPopoverController *popoverController;

    UIImage *patternImage;
    NSArray *patternRows;
    NSInteger currentIndex;
}

@end

@implementation SelectionViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"KnitKnack";

        // Add the select image icon to the left
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                               target:self
                                                                                               action:@selector(handleSelectImage:)] autorelease];

        // Add up/down buttons to the right
        UISegmentedControl *segControl = [[[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 90, 30)] autorelease];
        segControl.momentary = YES;
        segControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [segControl insertSegmentWithTitle:@"\u25B2" atIndex:0 animated:NO];
        [segControl insertSegmentWithTitle:@"\u25BC" atIndex:1 animated:NO];
        [segControl addTarget:self action:@selector(handleUpDown:) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segControl];

        // Create the image view and set it as the main view of the controller
        imageView = [[UIImageView alloc] init];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.view = imageView;

        // Create and add the label to the image view
        label = [[UILabel alloc] initWithFrame:CGRectMake(4, 4, 100, 20)];
        [imageView addSubview:label];

        patternImage = nil;
        patternRows = nil;
        currentIndex = 0;
    }
    return self;
}

- (void)dealloc {
    [popoverController release];
    [imageView release];
    [patternImage release];
    [patternRows release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)handleSelectImage:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.mediaTypes = @[(id)kUTTypeImage];
        imagePickerController.delegate = self;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            if (popoverController == nil) {
                popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
            }
            [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        } else {
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [popoverController dismissPopoverAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    if (image == nil) {
        NSLog(@"Image selected is nil");
        return;
    }

    patternImage = [image retain];
    patternRows = [[self processImage:image] retain];
    currentIndex = 0;

    imageView.image = patternImage;
    label.text = nil;
}

- (void)handleUpDown:(id)sender {
    if (patternRows == nil) {
        return;
    }
    
    UISegmentedControl *segControl = (UISegmentedControl *)sender;
    switch (segControl.selectedSegmentIndex) {
        case 0:
            currentIndex = currentIndex - 1;
            if (currentIndex < 0) {
                currentIndex = [patternRows count] - 1;
            }
            break;
            
        case 1:
            currentIndex = currentIndex + 1;
            if (currentIndex == [patternRows count]) {
                currentIndex = 0;
            }
            break;
        default:
            break;
    }

    NSValue *value = [patternRows objectAtIndex:currentIndex];
    if (value == nil) {
        return;
    }
    CGRect rect = [value CGRectValue];

    // Crop the image to the current row
    CGImageRef imageRef = [patternImage CGImage];
    CGImageRef rowImageRef = [self cropImage:imageRef toRect:rect];

    imageView.image = [UIImage imageWithCGImage:rowImageRef];
    if (currentIndex == 0) {
        label.text = nil;
    } else {
        label.text = [NSString stringWithFormat:@"%d", [patternRows count] - currentIndex];
    }
}

- (NSMutableArray *)processImage:(UIImage *)image {
    NSMutableArray *rows = [NSMutableArray array];

    // Get the CGImage from the selected UIImage
    CGImageRef imageRef = [image CGImage];
    size_t w = CGImageGetWidth(imageRef);
    size_t h = CGImageGetHeight(imageRef);
    
    CGImageRef greyImageRef = [self convertImageToGrayScale:imageRef];
    CGImageRef binaryImageRef = [self thresholdImage:greyImageRef withThreshold:0.90f];

#ifdef DEBUG
    // Save the binary image
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"binary.png"];
    [self saveImage:binaryImageRef toPath:path];
#endif

    // Find the gridlines
    NSMutableArray *gridLines = [self findGridLines:binaryImageRef];

    // Add a fake gridline at the height
    [gridLines addObject:[NSNumber numberWithInt:h - 1]];
    
    // Add a fake row the size of the image
    [rows addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, w, h)]];

    // Find the rows
    int index = 0;
    int prevRow = 0;
    for (NSNumber *rowNumber in gridLines) {
        int row = rowNumber.intValue;

        // Crop the row
        CGRect rect = CGRectMake(0, prevRow, w, row - prevRow + 2);
        [rows addObject:[NSValue valueWithCGRect:rect]];

#ifdef DEBUG
        // Crop and save the row
        CGImageRef rowImageRef = [self cropImage:imageRef toRect:rect];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"row.%d.png", index]];
        [self saveImage:rowImageRef toPath:path];
#endif

        prevRow = row;
        index++;
    }

    return rows;
}

- (CGImageRef)convertImageToGrayScale:(CGImageRef)imageRef {
    size_t w = CGImageGetWidth(imageRef);
    size_t h = CGImageGetHeight(imageRef);

    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

    // Create a grayscale context the same size as the source view
    CGContextRef context = CGBitmapContextCreate(nil, w, h, 8, 0, colorSpace, kCGImageAlphaNone);

    // Draw image into new grawscale context
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), imageRef);

    // Create a new image from the context
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);

    // Cleanup
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    return newImageRef;
}

- (CGImageRef)thresholdImage:(CGImageRef)imageRef withThreshold:(float)threshold {
    size_t w = CGImageGetWidth(imageRef);
    size_t h = CGImageGetHeight(imageRef);

    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

    // Create a grayscale context the same size as the source view
    CGContextRef context = CGBitmapContextCreate(nil, w, h, 8, 0, colorSpace, kCGImageAlphaNone);

    // Draw image into new grawscale context
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), imageRef);

    uint8_t *data = CGBitmapContextGetData(context);

    size_t n = CGBitmapContextGetHeight(context) * CGBitmapContextGetBytesPerRow(context);
    for (int i = 0; i < n; i++) {
        if (data[i] / 255.0f < threshold) {
            data[i] = 0x00;
        } else {
            data[i] = 0xFF;
        }
    }

    // Create a new image from the context
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);

    // Cleanup
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    return newImageRef;
}

- (NSMutableArray *)findGridLines:(CGImageRef)imageRef {
    NSMutableArray *array = [NSMutableArray array];

    size_t w = CGImageGetWidth(imageRef);
    size_t h = CGImageGetHeight(imageRef);
    int lasty = INT32_MIN;

    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

    // Create a grayscale context the same size as the source view
    CGContextRef context = CGBitmapContextCreate(nil, w, h, 8, 0, colorSpace, kCGImageAlphaNone);

    // Draw image into new grawscale context
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), imageRef);

    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);

    uint8_t *data = CGBitmapContextGetData(context);
    for (int y = 0; y < h; y++) {
        int sum = 0;
        for (int x = 0; x < w; x++) {
            if (data[y * bytesPerRow + x] == 0) {
                sum += 1;
            }
        }
        if (sum / (CGFloat)w > 0.75f) {
            if (y - lasty != 1) {
                [array addObject:[NSNumber numberWithInteger:y]];
            }
            lasty = y;
        }
    }

    // Cleanup
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    return array;
}

- (CGImageRef)cropImage:(CGImageRef)imageRef toRect:(CGRect)rect {
    return CGImageCreateWithImageInRect(imageRef, rect);
}

- (void)saveImage:(CGImageRef)imageRef toPath:(NSString *)path {
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:path];

    CGImageDestinationRef imageDestinationRef = CGImageDestinationCreateWithURL(url, (CFStringRef)@"public.png" , 1, NULL);
    CGImageDestinationAddImage(imageDestinationRef, imageRef, NULL);
    CGImageDestinationFinalize(imageDestinationRef);
    CFRelease(imageDestinationRef);
}

- (CGImageRef)loadImage:(NSString *)path {
    CGDataProviderRef dataProviderRef = CGDataProviderCreateWithFilename([path UTF8String]);
    CGImageRef imageRef = CGImageCreateWithPNGDataProvider(dataProviderRef, NULL, NO, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProviderRef);
    
    return imageRef;
}

@end
