//
//  ViewController.m
//  chat_sample
//
//  Created by 李晓春 on 15/8/12.
//  Copyright (c) 2015年 李晓春. All rights reserved.
//

#import "ViewController.h"
#import "ChatViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textName;
@property (weak, nonatomic) IBOutlet UITextField *textTalkTo;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* temp = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (temp.length == 0) {
        _btnStart.enabled = NO;
        return YES;
    }
    
    if (_textName == textField) {
        if (_textTalkTo.text.length) {
            _btnStart.enabled = YES;
        }
    }
    else {
        if (_textName.text.length) {
            _btnStart.enabled = YES;
        }
    }
    
    return YES;
}

- (IBAction)onButtonStartClicked:(id)sender {
    ChatViewController *viewController = [[ChatViewController alloc]initWithNibName:nil bundle:nil];
    viewController.strName = _textName.text;
    viewController.strTalkTo = _textTalkTo.text;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
