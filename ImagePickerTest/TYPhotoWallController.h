//
//  TYPhotoWallViewController.h
//  ImagePickerTest
//
//  Created by tony on 13-1-17.
//  Copyright (c) 2013年 tony. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ELCImages;
@class TYPhotoWallController;

@protocol TYPhotoWallControllerDelegate <NSObject>

- (void)tyPhotoWallControllerDidFinishPicking:(TYPhotoWallController*)tyPhotoWall clearImages:(ELCImages*)clearImages thumbnails:(ELCImages*)thumbnails;
- (void)tyPhotoWallControllerDidCancelPicking:(TYPhotoWallController *)mpPhotoWall;
@end

@interface TYPhotoWallController : UIViewController

@property (nonatomic, weak) id<TYPhotoWallControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger maxPictureNumber;//默认30张
- (void)importPicturesAnimated:(BOOL)animated;

@end
