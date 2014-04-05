//
//  ViewController.m
//  TestPushNotificationAndBackgroundFetch
//
//  Created by Sergio Cirasa on 30/09/13.
//  Copyright (c) 2013 Sergio Cirasa. All rights reserved.
//

#import "ViewController.h"
#import "Log.h"

@interface ViewController ()

@end

@implementation ViewController
//------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

}
//------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:KRefreshNotification object:nil];
    self.textView.text = [Log logs];
}
//------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:KRefreshNotification object:nil];
}
//------------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//------------------------------------------------------------------------------------------------------------
-(void)refresh:(NSNotificationCenter*)notification
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        self.textView.text = [Log logs];
        [self.textView scrollsToTop];
        NSRange range = NSMakeRange(self.textView.text.length - 1, 1);
        [self.textView scrollRangeToVisible:range];
    }];
    
}
//------------------------------------------------------------------------------------------------------------
#pragma mark - Button Action
- (IBAction)clearButtonAction:(id)sender {
    [Log removeLogs];
    self.textView.text = [Log logs];
}
//------------------------------------------------------------------------------------------------------------
-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:KRefreshNotification object:nil];
}
//------------------------------------------------------------------------------------------------------------

@end
