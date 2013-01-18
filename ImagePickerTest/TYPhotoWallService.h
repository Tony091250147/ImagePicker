//
//  TYPhotoWallService.h
//  ImagePickerTest
//
//  Created by tony on 13-1-17.
//  Copyright (c) 2013年 tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMLauncherDataSource.h"
@class HMLauncherData;

@interface TYPhotoWallService : NSObject <HMLauncherDataSource>

@property (nonatomic, strong) HMLauncherData *launcherData;

@end
