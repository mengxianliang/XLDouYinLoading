//
//  ViewController.m
//  XLDouYinLoadingExample
//
//  Created by MengXianLiang on 2018/11/28.
//  Copyright © 2018 MXL. All rights reserved.
//

#import "ViewController.h"
#import "XLDouYinLoading.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:23/255.0f green:25/255.0f blue:41/255.0f alpha:1];
    [self startLoading];
}

- (void)startLoading {
    [XLDouYinLoading showInView:self.view];
}

- (void)stopLoading {
    [XLDouYinLoading hideInView:self.view];
}

@end
