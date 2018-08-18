//
//  ViewController.m
//  UIWeb_WebViewJavascriptBridge
//
//  Created by cs on 2018/8/17.
//  Copyright © 2018年 cs. All rights reserved.
//

#import "ViewController.h"
#import "WebBridgeViewController.h"
#import "WKBridgeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self drawUI];
}

// drawUI
- (void)drawUI {
    
    UIButton *firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    [firstBtn setTitle:@"UIWebView--WebViewJavascriptBridgeL" forState:UIControlStateNormal];
    [firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    firstBtn.layer.borderColor = [[UIColor orangeColor] CGColor];
    firstBtn.layer.borderWidth = 1;
    [firstBtn addTarget:self action:@selector(firstBtnClick) forControlEvents:UIControlEventTouchUpInside];
    firstBtn.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.4);
    [self.view addSubview:firstBtn];
    
    UIButton *secondBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    [secondBtn setTitle:@"WKWebView--WebViewJavascriptBridge" forState:UIControlStateNormal];
    [secondBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    secondBtn.layer.borderColor = [[UIColor orangeColor] CGColor];
    secondBtn.layer.borderWidth = 1;
    [secondBtn addTarget:self action:@selector(secondBtnClick) forControlEvents:UIControlEventTouchUpInside];
    secondBtn.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.6);
    [self.view addSubview:secondBtn];
}

- (void)firstBtnClick {
    WebBridgeViewController *firstVC = [[WebBridgeViewController alloc] init];
    [self.navigationController pushViewController:firstVC animated:true];
}

- (void)secondBtnClick {
    WKBridgeViewController *secondVC = [[WKBridgeViewController alloc] init];
    [self.navigationController pushViewController:secondVC animated:true];
}

@end
