//
//  ChatViewController.m
//  chat_sample
//
//  Created by 李晓春 on 15/8/12.
//  Copyright (c) 2015年 李晓春. All rights reserved.
//

#import "ChatViewController.h"
#import "SIOSocket.h"

@interface ChatViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcBottom;

@property (weak, nonatomic) IBOutlet UITextView *textMessages;
@property (weak, nonatomic) IBOutlet UITextField *textInput;

@property (strong, nonatomic) SIOSocket *socket;
@property (strong, nonnull) NSString *strRoomName;
@property (strong, nonnull) NSString *strSocketId;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initChat];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat keyboardHight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    _lcBottom.constant = keyboardHight;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.34 animations:^{
        [weakSelf.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _lcBottom.constant = 0;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.34 animations:^{
        [weakSelf.view layoutIfNeeded];
    }];
}

- (IBAction)onButtonSendClicked:(id)sender {
    if (!_textInput.text.length) {
        return;
    }
    
    NSString *strUtf8 = [_textInput.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [_socket emit:@"client_message" args:[NSArray arrayWithObject:strUtf8]];
    [self addLine:_textInput.text sender:_strName];
    _textInput.text = @"";
}

- (void)initChat {
    __weak __typeof(self)weakSelf = self;
    
    NSString *strRoomName = @"";
    if ([_strName compare:_strTalkTo] == NSOrderedAscending) {
        strRoomName = [NSString stringWithFormat:@"%@&%@", _strName, _strTalkTo];
    }
    else {
        strRoomName = [NSString stringWithFormat:@"%@&%@", _strTalkTo, _strName];
    }
    
    _strRoomName = strRoomName;
    
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket)
     {
         weakSelf.socket = socket;
         
         socket.onConnect = ^()
         {
             [weakSelf onConnect];
         };
         
         [socket on:@"init" callback:^(NSArray *args) {
             [weakSelf onInit:args];
         }];
         
         [socket on:@"server_message" callback:^(NSArray *args) {
             [weakSelf onServerMessage:args];
         }];
         
         [socket on:@"client_message" callback:^(NSArray *args) {
             [weakSelf onClientMessage:args];
         }];
     }];
}

- (void)onConnect
{
    [_socket emit:@"init" args:nil];
    
    [_socket emit:@"set_name" args:[NSArray arrayWithObject:_strName]];
    
    [_socket emit:@"set_room" args:[NSArray arrayWithObject:_strRoomName]];
}

- (void)onInit:(NSArray*)args
{
    if (args.count != 1) {
        return;
    }
    
    if ([args[0]isKindOfClass:[NSString class]]) {
        _strSocketId = args[0];
    }
}

- (void)onServerMessage:(NSArray*)args
{
    if (args.count != 1) {
        return;
    }
    
    [self addLine:args[0] sender:@"The server"];
}

- (void)onClientMessage:(NSArray*)args
{
    if (args.count != 3) {
        return;
    }
    
    NSString *strSender = args[0];
    if ([strSender isEqualToString:_strSocketId]) {
        return;
    }
    
    [self addLine:[args[2] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] sender:args[1]];
}

- (void)addLine:(NSString*)strMessage sender:(NSString*)strSender
{
    NSString *strText = _textMessages.text;
    NSString *strTemp = [NSString stringWithFormat:@"%@: %@", strSender, strMessage];
    if (strText.length) {
        strText = [NSString stringWithFormat:@"%@\r\n%@", strText, strTemp];
    }
    else {
        strText = strTemp;
    }
    _textMessages.text = strText;
}

@end
