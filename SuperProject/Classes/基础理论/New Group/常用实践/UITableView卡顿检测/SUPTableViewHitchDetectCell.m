//
//  SUPTableViewHitchDetectCell.m
//  SuperProject
//
//  Created by zhi yi on 2025/7/26.
//  Copyright © 2025 superMan. All rights reserved.
//

#import "SUPTableViewHitchDetectCell.h"

@interface SUPTableViewHitchDetectCell () <CALayerDelegate>
@end

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

- (void)prepareForReuse {
    [super prepareForReuse];
    // 清理在卡顿模式下添加的演示视图
    for (int i = 0; i < 5; i++) {
        [[self.cardView viewWithTag:1000 + i] removeFromSuperview];
    }
    [[self.cardView viewWithTag:2000] removeFromSuperview];
    
    // 重置内容
    self.titleLabel.attributedText = nil;
    self.titleLabel.text = nil;
    self.avatarImageView.image = [UIImage imageNamed:@"icon"];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.cardView.frame = CGRectMake(10, 5, self.contentView.bounds.size.width - 20, self.contentView.bounds.size.height - 10);
    self.avatarImageView.frame = CGRectMake(10, 10, 60, 60);
    self.titleLabel.frame = CGRectMake(80, 10, self.cardView.bounds.size.width - 90, self.cardView.bounds.size.height - 20);
    
    // 关键：在这里更新 shadowPath
    // self.cardView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.cardView.bounds cornerRadius:self.cardView.layer.cornerRadius].CGPath;

    // --- 为卡顿模式下添加的视图设置frame ---
    UIView *customDrawView = [self.cardView viewWithTag:2000];
    if (customDrawView) {
        customDrawView.frame = CGRectMake(10, 80, self.cardView.bounds.size.width - 20, 50);
        if (customDrawView.layer.sublayers.firstObject) {
            customDrawView.layer.sublayers.firstObject.frame = customDrawView.bounds;
            // 触发重绘
            [customDrawView.layer.sublayers.firstObject setNeedsDisplay];
        }
    }
}

- (void)configureWithData:(NSDictionary *)data isOptimized:(BOOL)isOptimized {
    if (isOptimized) {
        // --- 优化模式 ---
        self.titleLabel.text = data[@"text"];
        
        // 1. 设置圆角和阴影（高效方式）
        self.cardView.layer.cornerRadius = 8.0;
        self.cardView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.cardView.layer.shadowOffset = CGSizeMake(0, 1);
        self.cardView.layer.shadowOpacity = 0.2;
        self.cardView.layer.shadowRadius = 3;
        // 在 layoutSubviews 中设置 shadowPath

        // 2. 异步加载图片
        self.avatarImageView.image = [UIImage imageNamed:@"icon"]; // 占位图
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
        // 1. 设置圆角和阴影（低效方式, 触发离屏渲染）
        self.cardView.layer.cornerRadius = 8.0;
        self.cardView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.cardView.layer.shadowOffset = CGSizeMake(0, 1);
        self.cardView.layer.shadowOpacity = 0.2;
        self.cardView.layer.shadowRadius = 3;
        self.cardView.layer.shadowPath = nil; // 不设置shadowPath，触发离屏渲染
        
        // // 2. 同步加载图片 (严重卡顿)
        // NSURL *url = [NSURL URLWithString:data[@"imageUrl"]];
        // // 模拟慢速网络
        // [NSThread sleepForTimeInterval:0.1];
        // NSData *imageData = [NSData dataWithContentsOfURL:url];
        // self.avatarImageView.image = [UIImage imageWithData:imageData];
        // 2. 异步加载图片
        self.avatarImageView.image = [UIImage imageNamed:@"icon"]; // 占位图
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
        
        // 3. 在这里设置圆角也会触发离屏渲染
        self.avatarImageView.layer.cornerRadius = 30.0;
        self.avatarImageView.clipsToBounds = YES;
        
        // --- 新增的卡顿原因 ---
        
        // 4. 耗时的文本计算 (加倍CPU负担)
        NSString *baseText = [NSString stringWithFormat:@"%@ %@", data[@"text"], data[@"text"]]; // 文本长度加倍
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:baseText];
        for (int i = 0; i < baseText.length; i++) {
            UIColor *color = [UIColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:1.0];
            UIFont *font = [UIFont systemFontOfSize:10 + arc4random_uniform(10)];
            [attributedString addAttributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName: font}
                                      range:NSMakeRange(i, 1)];
        }
        self.titleLabel.attributedText = attributedString;
        
        // 5. 创建大量子视图 (增加视图层级和渲染开销)
        // 创建一个 5x5 的 UILabel 网格
        for (int i = 0; i < 100; i++) {
            NSInteger tag = 3000 + i;
            // 确保不会重复添加
            if (![self.cardView viewWithTag:tag]) {
                UILabel *label = [[UILabel alloc] init];
                label.tag = tag;
                label.backgroundColor = [UIColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:0.8];
                label.layer.cornerRadius = 4.0;
                label.clipsToBounds = YES; // 每个带圆角的视图都会增加渲染开销
                label.text = [NSString stringWithFormat:@"%d", i];
                label.textAlignment = NSTextAlignmentCenter;
                [self.cardView addSubview:label];
            }
        }
    }
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    // 模拟复杂的绘制操作
    UIGraphicsPushContext(ctx);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    
    // 绘制大量随机线条
    for (int i = 0; i < 20; i++) {
        CGContextMoveToPoint(ctx, arc4random_uniform(layer.bounds.size.width), arc4random_uniform(layer.bounds.size.height));
        CGContextAddLineToPoint(ctx, arc4random_uniform(layer.bounds.size.width), arc4random_uniform(layer.bounds.size.height));
    }
    CGContextStrokePath(ctx);
    UIGraphicsPopContext();
}

@end
