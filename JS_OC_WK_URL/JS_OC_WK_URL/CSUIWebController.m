//
//  CSUIWebController.m
//  JS_OC_WK_URL
//
//  Created by cs on 2018/8/4.
//  Copyright © 2018年 cs. All rights reserved.
//

#import "CSUIWebController.h"
#import <AVFoundation/AVFoundation.h>

@interface CSUIWebController ()<UIWebViewDelegate>
/** webView */
@property(nonatomic, strong)UIWebView *webView;
@end

@implementation CSUIWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"UIWebView拦截 URL";
    [self drawUI];
}

// drawUI
- (void)drawUI {
    // web view
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.delegate = self;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    // btn
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"调JS" style:UIBarButtonItemStylePlain target:self action:@selector(transferJS)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - action

- (void)transferJS {
    NSString *jsStr = [NSString stringWithFormat:@"showAlert('%@')",@"这里是JS中alert弹出的message"];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = request.URL;
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:@"haleyaction"]) {
        [self handleCustomAction:URL];
        return NO;
    }

    return YES;
}

#pragma mark - dealwith custom action

- (void)handleCustomAction:(NSURL *)URL {
    NSString *host = [URL host];
    
    if ([host isEqualToString:@"shareClick"]) {
        [self share:URL];
    } else if ([host isEqualToString:@"getLocation"]) {
        [self getLocation:URL];
    } else if ([host isEqualToString:@"setBGColor"]) {
        [self setBGColor:URL];
    } else if ([host isEqualToString:@"payAction"]) {
        [self payAction:URL];
    } else if ([host isEqualToString:@"shake"]) {
        [self shakeAction];
    } else if ([host isEqualToString:@"back"]) {
        [self goBack];
    }
}

// share
- (void)share:(NSURL *)URL {
    NSArray *params = [URL.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dictArray = [paramStr componentsSeparatedByString:@"="];
        if (dictArray.count > 1) {
            NSString *decodeValue = [dictArray[1] stringByRemovingPercentEncoding];
            [tempDict setObject:decodeValue forKey:dictArray[0]];
        }
    }
    
    NSString *title = [tempDict objectForKey:@"title"];
    NSString *content = [tempDict objectForKey:@"content"];
    NSString *url = [tempDict objectForKey:@"url"];
    
    // 在这里只是分享的操作
    NSLog(@"原生分享操作");
    
    // 将分享的结果返回给 JS
    NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)getLocation:(NSURL *)URL {
    // 获取位置信息
    NSLog(@"原生获取位置信息操作");
    
    // 将结果返回给 JS
    NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')",@"广东省广州市白云区豪泉大厦"];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)setBGColor:(NSURL *)URL {
    NSArray *params = [URL.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dictArray = [paramStr componentsSeparatedByString:@"="];
        if (dictArray.count > 1) {
            NSString *decodeValue = [dictArray[1] stringByRemovingPercentEncoding];
            [tempDict setObject:decodeValue forKey:dictArray[0]];
        }
    }
    
    CGFloat r = [[tempDict objectForKey:@"r"] floatValue];
    CGFloat g = [[tempDict objectForKey:@"g"] floatValue];
    CGFloat b = [[tempDict objectForKey:@"b"] floatValue];
    CGFloat a = [[tempDict objectForKey:@"a"] floatValue];
    
    self.view.backgroundColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改背景色成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)payAction:(NSURL *)URL {
    NSArray *params = [URL.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dictArray = [paramStr componentsSeparatedByString:@"="];
        if (dictArray.count > 1) {
            NSString *decodeValue = [dictArray[1] stringByRemovingPercentEncoding];
            [tempDict setObject:decodeValue forKey:dictArray[0]];
        }
    }
    
    // 支付操作
    NSLog(@"原生支付操作");
    
    // 将支付结果返回给 js
    NSString *jsStr = [NSString stringWithFormat:@"payResult('%@')",@"支付成功"];
    [self.webView stringByEvaluatingJavaScriptFromString:jsStr];
}

- (void)shakeAction {
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void)goBack {
    [self.webView goBack];
}

@end
