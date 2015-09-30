//
//  NEOColorPickerFavoritesViewController.m
//
//  Created by Karthik Abram on 10/24/12.
//  Copyright (c) 2012 Neovera Inc.
//


/*
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

#import "NEOColorPickerFavoritesViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface NEOColorPickerFavoritesViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) CALayer *selectedColorLayer;

@end

@implementation NEOColorPickerFavoritesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.selectedColorText.length != 0) {
        self.selectedColorLabel.text = self.selectedColorText;
    }
    
    CGRect frame = CGRectMake(130, 16, 100, 40);
    UIImageView *checkeredView = [[UIImageView alloc] initWithFrame:frame];
    checkeredView.layer.cornerRadius = 6.0;
    checkeredView.layer.masksToBounds = YES;
    checkeredView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"colorPicker.bundle/color-picker-checkered"]];
    [self.view addSubview:checkeredView];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(130, 16, 100, 40);
    layer.cornerRadius = 6.0;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 2);
    layer.shadowOpacity = 0.8;
    
    [self.view.layer addSublayer:layer];
    self.selectedColorLayer = layer;
    self.selectedColorLayer.backgroundColor = self.selectedColor.CGColor;
  
#define kPadding 8
    CGFloat viewWidth = self.view.frame.size.width;
  
    CGFloat buttnWidth = (viewWidth - kPadding)/4 - kPadding;

    NSOrderedSet *colors = [NEOColorPickerFavoritesManager instance].favoriteColors;
    UIColor *pattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"colorPicker.bundle/color-picker-checkered"]];
    unsigned long count = [colors count];
    for (int i = 0; i < count; i++) {
        int page = i / 24;
        int x = i % 24;
        int column = x % 4;
        int row = x / 4;
        CGRect frame = CGRectMake(page * viewWidth + kPadding + (column * (buttnWidth + kPadding)), 8 + row * 48, buttnWidth, 40);
        
        UIImageView *checkeredView = [[UIImageView alloc] initWithFrame:frame];
        checkeredView.layer.cornerRadius = 6.0;
        checkeredView.layer.masksToBounds = YES;
        checkeredView.backgroundColor = pattern;
        [self.scrollView addSubview:checkeredView];
        
        CALayer *layer = [CALayer layer];
        layer.cornerRadius = 6.0;
        UIColor *color = [colors objectAtIndex:i];
        layer.backgroundColor = color.CGColor;
        layer.frame = frame;
        [self setupShadow:layer];
        [self.scrollView.layer addSublayer:layer];
    }
    unsigned long pages = (count - 1) / 24 + 1;
    
    self.scrollView.contentSize = CGSizeMake(pages * self.view.frame.size.width, 296);
    self.scrollView.delegate = self;
    CGRect curFrame = self.scrollView.frame;
    curFrame.size.width = self.view.frame.size.width;
    self.scrollView.frame = curFrame;
  
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorGridTapped:)];
    [self.scrollView addGestureRecognizer:recognizer];

    self.pageControl.numberOfPages = pages;
}


- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}


- (void) colorGridTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.scrollView];
  int viewWidth = self.view.frame.size.width;
    int page = point.x / viewWidth;
    int delta = (int)point.x % viewWidth;
  
#define kPadding 8
  
  CGFloat buttnWidth = (viewWidth)/4;
    int row = (int)((point.y - kPadding) / 48);
    int column = (int)((delta - kPadding) / (buttnWidth));
    int index = 24 * page + row * 4 + column;
    
    if (index < [[NEOColorPickerFavoritesManager instance].favoriteColors count])
    {
        self.selectedColor = [[NEOColorPickerFavoritesManager instance].favoriteColors objectAtIndex:index];
        self.selectedColorLayer.backgroundColor = self.selectedColor.CGColor;
        [self.selectedColorLayer setNeedsDisplay];
        if ([self.delegate respondsToSelector:@selector(colorPickerViewController:didChangeColor:)]) {
            [self.delegate colorPickerViewController:self didChangeColor:self.selectedColor];
        }
    }
}


- (IBAction)pageValueChange:(id)sender {
  int viewWidth = self.view.frame.size.width;
    [self.scrollView scrollRectToVisible:CGRectMake(self.pageControl.currentPage * viewWidth, 0, viewWidth, 296) animated:YES];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  int viewWidth = self.view.frame.size.width;
    self.pageControl.currentPage = scrollView.contentOffset.x / viewWidth;
}

@end