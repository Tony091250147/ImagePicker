//
//  TYPhotoWallViewController.m
//  ImagePickerTest
//
//  Created by tony on 13-1-17.
//  Copyright (c) 2013年 tony. All rights reserved.
//

#import "TYPhotoWallController.h"

#import "ELCImages.h"
//ui
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "GMGridView.h"



#import <QuartzCore/QuartzCore.h>

typedef enum TYImageListViewMode
{
    TYImageListViewMode_Editing,
    TYImageListViewMode_Normal,
    
    TYImageListViewMode_Count,
} TYImageListViewMode;

@interface TYPhotoWallController ()<GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewActionDelegate, ELCImagePickerControllerDelegate>

@property (nonatomic, assign) TYImageListViewMode currentMode;
@property (nonatomic, strong) ELCImages *clearImages;
@property (nonatomic, strong) ELCImages *thumbnails;
@property (nonatomic, strong) GMGridView *gmGridView;
@property (nonatomic, strong) UIBarButtonItem *editItem;
@property (nonatomic, assign) NSInteger lastDeleteItemIndexAsked;

@end

@implementation TYPhotoWallController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.clearImages = [[ELCImages alloc] init];
        self.thumbnails = [[ELCImages alloc] init];
        self.maxPictureNumber = 30;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //init navigation bar item
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneItemTouched:)];
    
    self.editItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editItemTouched:)];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelItemTouched:)];
    
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:doneButtonItem, self.editItem, nil];
    
    [self setNavigationTitle];
    
    //init mode
    self.currentMode = TYImageListViewMode_Normal;
    
    //init GridView
    NSInteger spacing = 8;
    self.gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    self.gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.gmGridView.backgroundColor = [UIColor clearColor];
    
    self.gmGridView.style = GMGridViewStylePush;
    self.gmGridView.itemSpacing = spacing;
    self.gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    self.gmGridView.centerGrid = NO;
    self.gmGridView.actionDelegate = self;
    self.gmGridView.sortingDelegate = self;
    self.gmGridView.dataSource = self;
    self.gmGridView.enableEditOnLongPress = YES;
    self.gmGridView.disableEditOnEmptySpaceTap = YES;
    
        
    [self.view addSubview:self.gmGridView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationTitle
{
    self.navigationItem.title = [NSString stringWithFormat:@"%d/%d",self.thumbnails.count,self.maxPictureNumber];
}
#pragma mark - Action Handler
- (void)doneItemTouched:(id)sender
{
    if (self.gmGridView.editing) {
        self.gmGridView.editing = NO;
    }
    
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(tyPhotoWallControllerDidFinishPicking:clearImages:thumbnails:)]) {
        [self.delegate tyPhotoWallControllerDidFinishPicking:self clearImages:self.clearImages thumbnails:self.thumbnails];
    }
}

- (void)cancelItemTouched:(id)sender
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(tyPhotoWallControllerDidCancelPicking:)]) {
        [self.delegate tyPhotoWallControllerDidCancelPicking:self];
    }
}

- (void)editItemTouched:(id)sender
{
    self.gmGridView.editing = !self.gmGridView.editing;
}
#pragma mark - utensil methods
- (void)importPicturesAnimated:(BOOL)animated
{
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
    NSInteger maxPic = self.maxPictureNumber - self.thumbnails.count;
    if (maxPic < 0) {
        maxPic = 0;
    }
    [albumController setMaxPictureNumber:maxPic];
	[elcPicker setDelegate:self];
    
    [self.navigationController presentViewController:elcPicker animated:animated completion:^{}];
    
}

#pragma mark ELCImagePickerControllerDelegate Methods
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithDict:(NSDictionary *)dict
{
    [self.clearImages addImageFromELCImages:[dict objectForKey:@"ELCClearImages"]];
    [self.thumbnails addImageFromELCImages:[dict objectForKey:@"ELCThumbnails"]];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    [self.gmGridView reloadData];
    [self setNavigationTitle];

}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}
#pragma mark GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    if (self.currentMode == TYImageListViewMode_Normal) {
        return self.thumbnails.count+1;
    } else
    {
        return self.thumbnails.count;
    }

}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(70, 70);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 8;
        
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    

    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (index == self.thumbnails.count) {
        imageView.image = [UIImage imageNamed:@"ty_addPhoto"];
    } else
    {
        imageView.image = [self.thumbnails imageAtIndex:index];
    }
    
    
    [cell.contentView addSubview:imageView];
    
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    if (index == self.thumbnails.count) {
        return NO;
    } else
    {
        return YES;        
    }
}

#pragma mark GMGridViewSortingDelegate
- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    if (![self moveImageAtIndex:oldIndex toIndex:newIndex]) {
        NSLog(@"Move Image order failed!");
    }
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{

    if (![self exchangeImageAtIndex:index1 withImageAtIndex:index2]) {
        NSLog(@"Exchange Image order failed!");
    }
}

#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    if (self.currentMode == TYImageListViewMode_Normal &&
        position == self.thumbnails.count) {
        if (self.thumbnails.count >= self.maxPictureNumber) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum Reached" message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        } else
        {
            [self importPicturesAnimated:YES];
        }

    }
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this item?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    
    [alert show];
    
    self.lastDeleteItemIndexAsked = index;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (![self removeImageAtIndex:self.lastDeleteItemIndexAsked]) {
            NSLog(@"Delete Image failed");
        }
        [self setNavigationTitle];
        [self.gmGridView removeObjectAtIndex:self.lastDeleteItemIndexAsked withAnimation:GMGridViewItemAnimationFade];
    }
}

- (void)GMGridView:(GMGridView *)gridView changedEdit:(BOOL)edit
{
    if (edit) {
        self.currentMode = TYImageListViewMode_Editing;
        self.editItem.title = @"Editing...";
    } else
    {
        self.currentMode = TYImageListViewMode_Normal;
        self.editItem.title = @"Edit";
    }
    [self.gmGridView reloadData];
}

#pragma mark - control images method
- (BOOL)moveImageAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    if (oldIndex < 0 ||
        oldIndex >= self.clearImages.count ||
        newIndex < 0 ||
        newIndex >= self.clearImages.count) {
        return NO;
    }
    
    NSObject *object = [self.clearImages.imageKeyArray objectAtIndex:oldIndex];
    [self.clearImages.imageKeyArray removeObject:object];
    [self.clearImages.imageKeyArray insertObject:object atIndex:newIndex];
    
    object = [self.thumbnails.imageKeyArray objectAtIndex:oldIndex];
    [self.thumbnails.imageKeyArray removeObject:object];
    [self.thumbnails.imageKeyArray insertObject:object atIndex:newIndex];
    
    return YES;
}

- (BOOL)exchangeImageAtIndex:(NSInteger)index1 withImageAtIndex:(NSInteger)index2
{
    if (index1 < 0 ||
        index1 >= self.clearImages.count ||
        index2 < 0 ||
        index2 >= self.clearImages.count) {
        return NO;
    }
    
    [self.clearImages.imageKeyArray exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    [self.thumbnails.imageKeyArray exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    
    return YES;
}

- (BOOL)removeImageAtIndex:(NSInteger)index
{
    if (index < 0 ||
        index >= self.clearImages.count) {
        return NO;
    }
    
    [self.clearImages removeImageAtIndex:index];
    [self.thumbnails removeImageAtIndex:index];
    return YES;
}

@end
