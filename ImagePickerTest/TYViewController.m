//
//  TYViewController.m
//  ImagePickerTest
//
//  Created by tony on 13-1-17.
//  Copyright (c) 2013年 tony. All rights reserved.
//

#import "TYViewController.h"
#import "TYPhotoWallController.h"
#import "ELCImages.h"

@interface TYViewController () <TYPhotoWallControllerDelegate>

@end

@implementation TYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"TYViewController did Receive Memory Warning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (IBAction)loadButtonTouched:(id)sender
{
    NSLog(@"load button touched");
    TYPhotoWallController *tyPhotoWallController = [[TYPhotoWallController alloc] initWithNibName:@"TYPhotoWallController" bundle:nil];
    tyPhotoWallController.delegate = self;
    tyPhotoWallController.maxPictureNumber = 50;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tyPhotoWallController];
    [self.navigationController presentViewController:navController animated:NO completion:^{}];
    [tyPhotoWallController importPicturesAnimated:NO];
}

#pragma mark - TYPhotoWallControllerDelegate
- (void)tyPhotoWallControllerDidCancelPicking:(TYPhotoWallController *)mpPhotoWall
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

- (void)tyPhotoWallControllerDidFinishPicking:(TYPhotoWallController *)tyPhotoWall clearImages:(ELCImages *)clearImages thumbnails:(ELCImages *)thumbnails
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    CGRect workingFrame = self.scrollView.frame;
	workingFrame.origin.x = 0;
	
    for (UIView *v in self.scrollView.subviews) {
        if (![v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
        }
    }
    
    NSLog(@"Clear Image count:%d",clearImages.count);
    for (NSUInteger index = 0; index < clearImages.count; index++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[clearImages imageAtIndex:index]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        imageView.frame = workingFrame;
        [self.scrollView addSubview:imageView];
        
        workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
    }
    
	[self.scrollView setPagingEnabled:YES];
	[self.scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
}
@end
