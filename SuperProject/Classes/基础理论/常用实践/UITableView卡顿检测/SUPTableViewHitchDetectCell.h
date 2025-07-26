//
//  SUPTableViewHitchDetectCell.h
//  SuperProject
//
//  Created by zhi yi on 2025/7/26.
//  Copyright © 2025 superMan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SUPTableViewHitchDetectCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *cardView;

- (void)configureWithData:(NSDictionary *)data isOptimized:(BOOL)isOptimized;

@end

NS_ASSUME_NONNULL_END
