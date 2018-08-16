//
//  ViewController.m
//  WK_MessageHandler
//
//  Created by chenshuang on 2018/8/15.
//  Copyright © 2018年 wenwen. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate, WKScriptMessageHandler>
/** wk*/
@property(nonatomic,strong)WKWebView *webView;
@property (strong, nonatomic)UIProgressView *progressView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self drawUI];
    
    [self initProgressView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // addScriptMessageHandler 很容易导致循环引用
    // 控制器 强引用了WKWebView,WKWebView copy(强引用了）configuration， configuration copy （强引用了）userContentController
    // userContentController 强引用了 self （控制器）
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"Location"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"Share"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"Color"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"GoBack"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 因此这里要记得移除handlers
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"Location"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"Share"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"Color"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"GoBack"];
}

#pragma mark - drawUI

- (void)drawUI {
    // WKWebViewConfiguration
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKPreferences *preference = [WKPreferences new];
    preference.javaScriptCanOpenWindowsAutomatically = YES;
    preference.minimumFontSize = 40.0;
    configuration.preferences = preference;
    
    // WKWebView
    CGRect webViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 0.8);
    self.webView = [[WKWebView alloc] initWithFrame:webViewFrame configuration:configuration];
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
}

- (void)initProgressView {
    CGFloat kScreenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 2)];
    progressView.tintColor = [UIColor redColor];
    progressView.trackTintColor = [UIColor lightGrayColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // message.body  --  Allowed types are NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull.
    if ([message.name isEqualToString:@"Location"]) {
        [self getLocation];
    } else if ([message.name isEqualToString:@"Share"]) {
        [self shareWithParams:message.body];
    } else if ([message.name isEqualToString:@"Color"]) {
        [self changeBGColor:message.body];
    }else if ([message.name isEqualToString:@"GoBack"]) {
        [self goBack];
    }
}

#pragma mark - function

- (void)getLocation {
    // 获取位置信息
    NSLog(@"获取位置信息");
    
    // 将结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')",@"广东省深圳市南山区学府路XXXX号"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
    
    NSString *jsStr2 = @"window.ctuapp_share_img";
    [self.webView evaluateJavaScript:jsStr2 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];

}

- (void)shareWithParams:(NSDictionary *)params {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *title = [params objectForKey:@"title"];
    NSString *content = [params objectForKey:@"content"];
    NSString *url = [params objectForKey:@"url"];
    
    // 在这里执行分享的操作
    NSLog(@"在这里执行分享的操作");
    
    // 将分享结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id result, NSError *error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)changeBGColor:(NSArray *)params {
    if (![params isKindOfClass:[NSArray class]]) {
        return;
    }
    
    if (params.count < 4) {
        return;
    }
    
    CGFloat r = [params[0] floatValue];
    CGFloat g = [params[1] floatValue];
    CGFloat b = [params[2] floatValue];
    CGFloat a = [params[3] floatValue];
    
    self.view.backgroundColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

- (void)goBack {
    [self.webView goBack];
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
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newProgress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newProgress == 1) {
            [self.progressView setProgress:1 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            });
        } else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newProgress animated:YES];
        }
    }
}

@end
