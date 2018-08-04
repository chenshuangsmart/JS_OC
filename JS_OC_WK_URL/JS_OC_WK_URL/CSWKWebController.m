//
//  CSWKWebController.m
//  JS_OC_WK_URL
//
//  Created by cs on 2018/8/4.
//  Copyright © 2018年 cs. All rights reserved.
//

#import "CSWKWebController.h"
#import <WebKit/WebKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CSWKWebController ()<WKNavigationDelegate, WKUIDelegate>
/** WKwebView */
@property(nonatomic, strong)WKWebView *webView;
/** progress */
@property(nonatomic, strong)UIProgressView *progressView;

@end

@implementation CSWKWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"WKWebView 拦截 URL 请求";
    
    //
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"调JS" style:UIBarButtonItemStylePlain target:self action:@selector(transferJS)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self initWKWebView];
    
    [self.view addSubview:self.progressView];
    
    // 监听进度条
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark - init

- (void)initWKWebView {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 30.0;
    configuration.preferences = preferences;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    
    // load
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:@""];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
}

#pragma mark - action

- (void)transferJS {
    
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:@"haleyaction"]) {
        [self handleCustomAction:URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView &&  [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newProgress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newProgress == 1) {
            [self.progressView setProgress:1];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = true;
                [self.progressView setProgress:0 animated:NO];
            });
        } else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newProgress animated:YES];
        }
    }
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
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)getLocation:(NSURL *)URL {
    // 获取位置信息
    NSLog(@"原生获取位置信息操作");
    
    // 将结果返回给 JS
    NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')",@"广东省广州市白云区豪泉大厦"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
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
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)shakeAction {
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void)goBack {
    [self.webView goBack];
}

#pragma mark - lazy

- (UIProgressView *)progressView {
    if (_progressView == nil) {
        CGFloat kScreenWidth = [[UIScreen mainScreen] bounds].size.width;
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 2)];
        _progressView.tintColor = [UIColor redColor];
        _progressView.trackTintColor = [UIColor lightGrayColor];
    }
    return _progressView;
}

@end
