//
//  TYViewController.h
//  ImagePickerTest
//
//  Created by tony on 13-1-17.
//  Copyright (c) 2013年 tony. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (IBAction)loadButtonTouched:(id)sender;

@end
