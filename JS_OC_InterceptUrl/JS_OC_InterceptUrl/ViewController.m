//
//  ViewController.m
//  JS_OC_InterceptUrl
//
//  Created by cs on 2018/8/2.
//  Copyright © 2018年 cs. All rights reserved.
//

#import "ViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"

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

    UIButton *firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [firstBtn setTitle:@"方式一" forState:UIControlStateNormal];
    [firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    firstBtn.layer.borderColor = [[UIColor orangeColor] CGColor];
    firstBtn.layer.borderWidth = 1;
    [firstBtn addTarget:self action:@selector(firstBtnClick) forControlEvents:UIControlEventTouchUpInside];
    firstBtn.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.4);
    [self.view addSubview:firstBtn];
    
    UIButton *secondBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [secondBtn setTitle:@"方式二" forState:UIControlStateNormal];
    [secondBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    secondBtn.layer.borderColor = [[UIColor orangeColor] CGColor];
    secondBtn.layer.borderWidth = 1;
    [secondBtn addTarget:self action:@selector(secondBtnClick) forControlEvents:UIControlEventTouchUpInside];
    secondBtn.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.6);
    [self.view addSubview:secondBtn];
}

- (void)firstBtnClick {
    FirstViewController *firstVC = [[FirstViewController alloc] init];
    [self.navigationController pushViewController:firstVC animated:true];
}

- (void)secondBtnClick {
    SecondViewController *secondVC = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:secondVC animated:true];
}

@end
