//
//  CustomTableViewCell.m
//  KavaTask
//
//  Created by roko on 21.06.13.
//  Copyright (c) 2013 roko. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "AppDelegate.h"
#import "DateField.h"

@implementation CustomTableViewCell

//+ (UIImage *) defaultPhoto
//{
//    static UIImage * defaultPhoto;
//    @synchronized(self) {
//        if (nil == defaultPhoto) {
//            defaultPhoto = [UIImage imageNamed:DefaultUserImagePath];
//        }
//        return defaultPhoto;
//    }
//}

//+ (UIImage *)defaultPhoto
//{
//    static UIImage *defaultPhoto = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        defaultPhoto = [[UIImage alloc] initWithContentsOfFile:DefaultUserImagePath];
//    });
//    return defaultPhoto;
//}

+ (UIImage *)defaultPhoto
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [UIImage imageNamed:DefaultUserImagePath];
    });
    return _sharedObject;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Configure Main Label
        self.priorityField.enableCut = NO;
        self.priorityField.enablePaste = NO;
        //self.showsReorderControl = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIViewContentMode contentMode;
    CGSize imageSize = _userPhoto.image.size;
    CGSize viewSize = _userPhoto.frame.size;
    if (viewSize.width > imageSize.width && viewSize.height > imageSize.height) {
        contentMode = UIViewContentModeCenter;
    } else {
        contentMode = UIViewContentModeScaleAspectFit;
    }
    _userPhoto.contentMode = contentMode;
}

@end
