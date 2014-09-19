//
//  FirstViewController.m
//  tab
//
//  Created by kwangsik.shin on 2014. 9. 18..
//  Copyright (c) 2014년 Arewith. All rights reserved.
//

#import "FirstViewController.h"
#import "AWTabBarController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.


    AWTabBarController * tbc = (AWTabBarController*)(self.tabBarController);

    NSMutableArray * array = [NSMutableArray array];
    for (long i = 0; i<2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [array addObject:button];

        [button setTitle:[NSString stringWithFormat:@"btn %ld", i] forState:UIControlStateNormal];

        button.backgroundColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.8 alpha:1];//%%% buttoncolors
    }
    tbc.view.backgroundColor = [UIColor whiteColor];
    tbc.selectedSegmentColor = [UIColor redColor];
    tbc.customSegmentButtons = array;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
