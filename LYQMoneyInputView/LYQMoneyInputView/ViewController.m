//
//  ViewController.m
//  LYQMoneyInputView
//
//  Created by Alphts on 2017/3/6.
//  Copyright © 2017年 Alphts. All rights reserved.
//

#import "ViewController.h"
#import "LYQMoneyInputView.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tf;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    LYQMoneyInputView *numberPadView = [[LYQMoneyInputView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 254)];
    
    numberPadView.textField =  self.tf;

}


@end
