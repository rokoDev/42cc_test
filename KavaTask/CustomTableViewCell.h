//
//  CustomTableViewCell.h
//  KavaTask
//
//  Created by roko on 21.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *userLink;

+ (UIImage*)defaultPhoto;

@end
