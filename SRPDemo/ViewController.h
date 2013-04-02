//
//  ViewController.h
//  SRPDemo
//
//  Created by David Siegel on 03.04.13.
//  Copyright (c) 2013 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic,strong) IBOutlet UITextField * password;
@property (nonatomic,strong) IBOutlet UILabel * result;

@end
