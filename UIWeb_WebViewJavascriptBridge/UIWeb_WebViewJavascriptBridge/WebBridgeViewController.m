//
//  WebBridgeViewController.m
//  UIWeb_WebViewJavascriptBridge
//
//  Created by cs on 2018/8/17.
//  Copyright © 2018年 cs. All rights reserved.
//

#import "WebBridgeViewController.h"
#import <WebViewJavascriptBridge.h>

@interface WebBridgeViewController ()
/** webView */
@property(nonatomic, strong)UIWebView *webView;
/** bridge */
@property(nonatomic, strong)WebViewJavascriptBridge *webViewBridge;

@end

@implementation WebBridgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupInit];
    [self drawUI];
    // 添加JS 要调用的Native 功能
    [self registerNativeFunctions];
}

#pragma mark - setupInit

- (void)setupInit {
    self.title = @"UIWebView--WebViewJavascriptBridgeL";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

#pragma mark - drawUI

- (void)drawUI {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(rightClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:htmlURL];
    
    // UIWebView 滚动的比较慢，这里设置为正常速度
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.webView loadRequest:request];
    
    // WebViewJavascriptBridge
    self.webViewBridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.webViewBridge setWebViewDelegate:self];
}

#pragma mark - action

- (void)rightClick
{
    //    // 如果不需要参数，不需要回调，使用这个
    //    [_webViewBridge callHandler:@"testJSFunction"];
    //    // 如果需要参数，不需要回调，使用这个
    //    [_webViewBridge callHandler:@"testJSFunction" data:@"一个字符串"];
    // 如果既需要参数，又需要回调，使用这个
    [_webViewBridge callHandler:@"testJSFunction" data:@"一个字符串" responseCallback:^(id responseData) {
        NSLog(@"调用完JS后的回调：%@",responseData);
    }];
}

#pragma mark - private function

- (void)registerNativeFunctions {
    [self registShareFunction];
    
    [self registLocationFunction];
    
    [self registPayFunction];
}

- (void)registShareFunction {
    [self.webViewBridge registerHandler:@"shareClick" handler:^(id data, WVJBResponseCallback responseCallback) {
        // data 的类型与 JS中传的参数有关
        NSDictionary *tempDic = data;
        // 在这里执行分享的操作
        NSString *title = [tempDic objectForKey:@"title"];
        NSString *content = [tempDic objectForKey:@"content"];
        NSString *url = [tempDic objectForKey:@"url"];
        NSLog(@"JS 传递给 OC 的参数:%@",[NSString stringWithFormat:@"分享成功:%@,%@,%@",title,content,url]);
        
        // 将分享的结果返回到JS中
        NSString *result = [NSString stringWithFormat:@"分享成功:%@,%@,%@",title,content,url];
        responseCallback(result);
    }];
}

- (void)registLocationFunction {
    [self.webViewBridge registerHandler:@"locationClick" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 获取位置信息
        
        // 将结果返回给 JS
        NSString *location = @"广东省广州市白云区豪泉大厦";
        responseCallback(location);
    }];
}

- (void)registPayFunction {
    [self.webViewBridge registerHandler:@"payClick" handler:^(id data, WVJBResponseCallback responseCallback) {
        // data 的类型与 JS中传的参数有关
        NSDictionary *tempDic = data;
        
        NSString *orderNo = [tempDic objectForKey:@"order_no"];
        long long amount = [[tempDic objectForKey:@"amount"] longLongValue];
        NSString *subject = [tempDic objectForKey:@"subject"];
        NSString *channel = [tempDic objectForKey:@"channel"];
        // 支付操作...
        NSLog(@"支付操作:%@", [NSString stringWithFormat:@"支付成功:%@,%@,%@,%ld",orderNo,subject,channel,amount]);
        
        // 将分享的结果返回到JS中
        NSString *result = [NSString stringWithFormat:@"支付成功:%@,%@,%@",orderNo,subject,channel];
        responseCallback(result);
    }];
}


@end
