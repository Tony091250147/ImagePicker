//
//  TYPhotoWallIcon.m
//  ImagePickerTest
//
//  Created by tony on 13-1-17.
//  Copyright (c) 2013年 tony. All rights reserved.
//

#import "TYPhotoWallIcon.h"

@implementation TYPhotoWallIcon

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL) hitCloseButton:(CGPoint)point {
    return (CGRectContainsPoint(self.closeRect, point));
}

- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat availableWidth = self.iconImage.size.width;
    
    // Icon
    CGFloat x = floor((self.bounds.size.width - availableWidth) / 2);
    CGFloat y = 10;
    CGRect buttonRect = CGRectMake(x, y, self.iconImage.size.width, self.iconImage.size.height);
    
    // Highlighted
    if (self.highlighted && (self.canBeTapped || self.canBeDragged)) {
        [[UIColor darkGrayColor] setFill];
        UIBezierPath *outerPath = [UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:11.0];
        CGContextSaveGState(context);
        [outerPath addClip];
        CGContextFillRect(context, buttonRect);
        CGContextRestoreGState(context);
    }
    CGFloat alpha = 1.0;
    if (self.canBeDragged == NO) {
        alpha = 0.3;
    }
    [self.iconImage drawInRect:buttonRect blendMode:kCGBlendModeOverlay alpha:alpha];
    
    // Close Button
    if (!self.hideDeleteImage) {
        [self.closeImage drawInRect:self.closeRect];
    }
    
}
/*
- (void) setIconImageFromIconPath:(NSString *)iconPath {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [bundle pathForResource:self.launcherItem.iconPath ofType:nil];
    UIImage *aIconImage = [UIImage imageWithContentsOfFile:imagePath];
    
    // I've used the static imageNamed function before, but imageNamed doesn't work in unittests.
    //
    // UIImage *aIconImage = [UIImage imageNamed:self.launcherItem.iconPath];
    // UIImage *aBackgroundImage = [UIImage imageNamed:self.launcherItem.iconBackgroundPath];
    NSString *aBackgroundImagePath = [bundle pathForResource:self.launcherItem.iconBackgroundPath ofType:nil];
    UIImage *aBackgroundImage = [UIImage imageWithContentsOfFile:aBackgroundImagePath];
    
    NSParameterAssert(aIconImage != nil);
    self.iconImage = [self mergeBackgroundImage:aBackgroundImage  withTopImage:aIconImage];
}
*/
@end
