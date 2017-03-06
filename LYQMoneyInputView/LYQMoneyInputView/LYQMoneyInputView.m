//
//  LYQMoneyInputView.m
//  LYQMoneyInputView
//
//  Created by Alphts on 2017/3/6.
//  Copyright © 2017年 Alphts. All rights reserved.
//

#import "LYQMoneyInputView.h"

#define DEFAULT_VOID_COLOR [UIColor whiteColor]
@interface LYQMoneyInputView ()<UIInputViewAudioFeedback>{
    UITextField *_textField;
}

@property (nonatomic,assign) id<UITextInput>delegate;

@property (nonatomic, weak) UILabel *lb_line;
@property (nonatomic, weak) UIView *numberView;
@property (nonatomic, weak) UIButton *btn_hide;
@property (nonatomic, weak) UIButton *btn_delete;

@end

NSInteger i;

@implementation LYQMoneyInputView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        i = 0;
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    //顶部线条
    UILabel *lb_line = [[UILabel alloc] init];
    lb_line.backgroundColor = [self colorWithHexString:@"#c5c5c5"];
    self.lb_line = lb_line;
    [self addSubview:lb_line];
    
    //隐藏按钮
    UIButton *btn_hide = [[UIButton alloc] init];
    [btn_hide setTitle:@"隐藏按钮" forState:UIControlStateNormal];
     btn_hide.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:20];
    self.btn_hide = btn_hide;
    btn_hide.backgroundColor = [UIColor whiteColor];
    [btn_hide setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_hide addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    btn_hide.tag = 12;
    [self addSubview:btn_hide];
    
    //输入键盘
    UIView *numberView = [[UIView alloc] init];
    numberView.backgroundColor = [self colorWithHexString:@"#d2d2d2"];
    self.numberView = numberView;
    [self addSubview:numberView];
    
    for (int i = 1; i<=9; i++) {
        [self creatButtonWithTitle:[NSString stringWithFormat:@"%d",i]];
    }
    
    [self creatButtonWithTitle:@"."];
    [self creatButtonWithTitle:@"0"];
    [self creatButtonWithTitle:@"C"];
    
}

- (void)creatButtonWithTitle:(NSString *)title{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:21];
    [btn addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];

    if (title.integerValue) {
        btn.tag = title.integerValue;
    }
    
    if ([title isEqualToString:@"0"]) {
        btn.tag = 0;
    }
    if ([title isEqualToString:@"."]) {
         btn.tag = 10;
    }
    if ([title isEqualToString:@"C"]) {
         btn.tag = 11;
        self.btn_delete = btn;
    }
    
    [self.numberView addSubview:btn];
}

- (void)didClickButton:(UIButton *)sender{
    
    NSRange dot = [_textField.text rangeOfString:@"."];

    switch (sender.tag) {
            
        case 12:
            [_textField resignFirstResponder];
            break;
        case 10:// 如果小数点位置不正确  还需要做删除操作
            if(i>10){
                break;
            }
            // `00.12`这种输入也不允许 --> 输入格式的正确 拿到字符串再判断更合适
//            if (_textField.text.length>1) {
//                if ([[_textField.text substringToIndex:1] isEqualToString:@"0"]) {
//                    break;
//                }
//            }
            
            // 字符串首字符串不能是`.`
            if ([_textField.text isEqualToString:@""]) {
                break;
            }
            
            if (dot.location == NSNotFound) {
                // only 1 decimal dot allowed
                [self.delegate insertText:@"."];
                [[UIDevice currentDevice] playInputClick];
                i++;
                
                // 光标移动到中间输入`.`
                NSInteger number = _textField.text.length - [_textField.text rangeOfString:@"."].location - 3;
                if (number>0) {
                    _textField.text = [_textField.text substringToIndex:[_textField.text rangeOfString:@"."].location + 3];
                    i = i-number;
                }
            }
            break;
        case 11:
            if(_textField.text.length==0){
                break;
            }
            [self.delegate deleteBackward];
            [[UIDevice currentDevice] playInputClick];
            i--;
            break;
            
        default:
            if(i>=10){
                break;
            }
            // max 2 decimals
            else if(i<10){
                if (dot.location == NSNotFound || _textField.text.length <= dot.location + 2) {
                    [self.delegate insertText:[NSString stringWithFormat:@"%ld", (long)sender.tag]];
                    [[UIDevice currentDevice] playInputClick];
                    i++;
                }
            }
            break;
            
    }

}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.lb_line.frame = CGRectMake(0, 0, width, 1);
    _btn_hide.frame = CGRectMake(0, 1, width, 40);
    self.numberView.frame = CGRectMake(0, 41, width, height-41);
    
    //九宫格布局
    CGFloat margin = 1;
    CGFloat btn_width = (width - 2*margin)/3;
    CGFloat btn_height = (height-41-4*margin)/4;
    
    [self.numberView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger col = idx % 3;
        NSInteger row = idx / 3;
        obj.frame = CGRectMake(col*(btn_width+margin), row*(btn_height+margin)+margin, btn_width, btn_height);
    }];
    
    
    
}


- (id<UITextInput>)delegate {
    return _textField;
}


- (UITextField *)textField {
    return _textField;
}

- (void)setTextField:(UITextField *)textField {
    _textField = textField;
    _textField.inputView = self;
}



//十六进制转UIcolor
- (UIColor *)colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    
    if ([cString length] < 6)
        return DEFAULT_VOID_COLOR;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return DEFAULT_VOID_COLOR;
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

#pragma mark - UIInputViewAudioFeedback delegate

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}




@end




















