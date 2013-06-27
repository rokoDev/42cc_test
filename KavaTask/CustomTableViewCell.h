//
//  CustomTableViewCell.h
//  KavaTask
//
//  Created by roko on 21.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DateField;

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet DateField *priorityField;

@property (weak, nonatomic) NSMutableDictionary *infoDict;


//@property (strong, nonatomic) NSString *userID;
//@property (strong, nonatomic) NSString *userLink;

+ (UIImage*)defaultPhoto;

@end
