//
//  SUPTableViewHitchDetectCell.m
//  SuperProject
//
//  Created by zhi yi on 2025/7/26.
//  Copyright © 2025 superMan. All rights reserved.
//

#import "SUPTableViewHitchDetectCell.h"

@implementation SUPTableViewHitchDetectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        self.cardView = [[UIView alloc] init];
        self.cardView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.cardView];
        
        self.avatarImageView = [[UIImageView alloc] init];
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.cardView addSubview:self.avatarImageView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.cardView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.cardView.frame = CGRectMake(10, 5, self.contentView.bounds.size.width - 20, self.contentView.bounds.size.height - 10);
    self.avatarImageView.frame = CGRectMake(10, 10, 60, 60);
    self.titleLabel.frame = CGRectMake(80, 10, self.cardView.bounds.size.width - 90, self.cardView.bounds.size.height - 20);
    
    // 关键：在这里更新 shadowPath
    self.cardView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.cardView.bounds cornerRadius:self.cardView.layer.cornerRadius].CGPath;
}

- (void)configureWithData:(NSDictionary *)data isOptimized:(BOOL)isOptimized {
    self.titleLabel.text = data[@"text"];
    
    if (isOptimized) {
        // --- 优化模式 ---
        // 1. 设置圆角和阴影（高效方式）
        self.cardView.layer.cornerRadius = 8.0;
        self.cardView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.cardView.layer.shadowOffset = CGSizeMake(0, 1);
        self.cardView.layer.shadowOpacity = 0.2;
        self.cardView.layer.shadowRadius = 3;
        // 在 layoutSubviews 中设置 shadowPath

        // 2. 异步加载图片
        self.avatarImageView.image = [UIImage imageNamed:@"placeholder"]; // 占位图
        self.avatarImageView.layer.cornerRadius = 30.0;
        self.avatarImageView.clipsToBounds = YES;
        
        NSURL *url = [NSURL URLWithString:data[@"imageUrl"]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 模拟慢速网络
            [NSThread sleepForTimeInterval:0.1];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 检查cell是否还显示在屏幕上
                if ([((UITableView *)self.superview).visibleCells containsObject:self]) {
                    self.avatarImageView.image = image;
                }
            });
        });

    } else {
        // --- 卡顿模式 ---
        // 1. 设置圆角和阴影（低效方式）
        self.cardView.layer.cornerRadius = 8.0;
        self.cardView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.cardView.layer.shadowOffset = CGSizeMake(0, 1);
        self.cardView.layer.shadowOpacity = 0.2;
        self.cardView.layer.shadowRadius = 3;
        self.cardView.layer.shadowPath = nil; // 不设置shadowPath，触发离屏渲染
        
        // 2. 同步加载图片 (严重卡顿)
        NSURL *url = [NSURL URLWithString:data[@"imageUrl"]];
        // 模拟慢速网络
        [NSThread sleepForTimeInterval:0.1];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        self.avatarImageView.image = [UIImage imageWithData:imageData];
        
        // 3. 在这里设置圆角也会触发离屏渲染
        self.avatarImageView.layer.cornerRadius = 30.0;
        self.avatarImageView.clipsToBounds = YES;
    }
}

@end
