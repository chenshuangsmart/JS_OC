//
//  ViewController.m
//  JS_OC_WK_URL
//
//  Created by cs on 2018/8/4.
//  Copyright © 2018年 cs. All rights reserved.
//

#import "ViewController.h"
#import "CSUIWebController.h"
#import "CSWKWebController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self drawUI];
}

// drawUI
- (void)drawUI {
    UIButton *firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [firstBtn setTitle:@"UIWebView 拦截 URL" forState:UIControlStateNormal];
    [firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    firstBtn.layer.borderColor = [[UIColor orangeColor] CGColor];
    firstBtn.layer.borderWidth = 1;
    [firstBtn addTarget:self action:@selector(firstBtnClick) forControlEvents:UIControlEventTouchUpInside];
    firstBtn.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.4);
    [self.view addSubview:firstBtn];
    
    UIButton *secondBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [secondBtn setTitle:@"WKWebView 拦截 UIRL" forState:UIControlStateNormal];
    [secondBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    secondBtn.layer.borderColor = [[UIColor orangeColor] CGColor];
    secondBtn.layer.borderWidth = 1;
    [secondBtn addTarget:self action:@selector(secondBtnClick) forControlEvents:UIControlEventTouchUpInside];
    secondBtn.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.6);
    [self.view addSubview:secondBtn];
}

- (void)firstBtnClick {
    CSUIWebController *firstVC = [[CSUIWebController alloc] init];
    [self.navigationController pushViewController:firstVC animated:true];
}

- (void)secondBtnClick {
    CSWKWebController *secondVC = [[CSWKWebController alloc] init];
    [self.navigationController pushViewController:secondVC animated:true];
}

@end
