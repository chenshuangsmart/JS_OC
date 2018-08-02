//
//  ViewController.m
//  JS_OC_InterceptUrl
//
//  Created by cs on 2018/8/2.
//  Copyright © 2018年 cs. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate>
/** webView */
@property(nonatomic, strong)UIWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self drawUI];
}

// drawUI
- (void)drawUI {
    // web view
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.delegate = self;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"First" ofType:@"html"];
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
    NSURL * url = [request URL];
    if ([[url scheme] isEqualToString:@"firstclick"]) {  // firstClick://shareClick?title=分享的标题&content=分享的内容&url=链接地址&imagePath=图片地址
        NSArray *params = [url.query componentsSeparatedByString:@"&"];
        
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
        NSMutableString *strM = [NSMutableString string];
        for (NSString *paramStr in params) {
            NSArray *dictArray = [paramStr componentsSeparatedByString:@"="];
            if (dictArray.count > 1) {
                NSString *decodeValue = [dictArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                decodeValue = [decodeValue stringByRemovingPercentEncoding];
                [tempDict setObject:decodeValue forKey:dictArray[0]];
                [strM appendString:decodeValue];
            }
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"这是OC原生的弹出窗" message:strM delegate:self cancelButtonTitle:@"收到" otherButtonTitles:nil];
        [alertView show];
        NSLog(@"tempDic:%@",tempDict);
        return NO;
    }
    return YES;
}

@end
