//
//  SecondViewController.m
//  JS_OC_InterceptUrl
//
//  Created by cs on 2018/8/2.
//  Copyright © 2018年 cs. All rights reserved.
//

#import "SecondViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface SecondViewController ()
/** webView */
@property(nonatomic, strong)UIWebView *webView;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"方式二";
    [self drawUI];
    [self setupData];
}

- (void)drawUI {
    // web view
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor whiteColor];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Second" ofType:@"html"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    // btn
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"调JS" style:UIBarButtonItemStylePlain target:self action:@selector(transferJS)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setupData {
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //定义好JS要调用的方法, share就是调用的share方法名
    context[@"share"] = ^() {
        NSLog(@"+++++++Begin Log+++++++");
        NSArray *args = [JSContext currentArguments];
        NSMutableString *strM = [NSMutableString string];
        for (JSValue *jsVal in args) {
            NSLog(@"%@", jsVal.toString);
            [strM appendString:jsVal.toString];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"这是OC原生的弹出窗" message:strM delegate:self cancelButtonTitle:@"收到" otherButtonTitles:nil];
            [alertView show];
        });
        
        
        NSLog(@"-------End Log-------");
    };
    
    [context evaluateScript:@"var arr = [3, 4, 'abc'];"];
}

#pragma mark - action

- (void)transferJS {
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *textJS = @"showAlert('这里是JS中alert弹出的message')";
    [context evaluateScript:textJS];
}

@end
