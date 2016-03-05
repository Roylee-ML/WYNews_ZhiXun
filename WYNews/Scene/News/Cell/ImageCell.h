//
//  ImageCell.h
//  WYNews
//
//  Created by lanou3g on 15/6/1.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
@interface ImageCell : UITableViewCell

//@property(nonatomic,strong)UIImageView * imgView;
//@property(nonatomic,strong)UIImageView * imgView1;
//@property(nonatomic,strong)UIImageView * imgView2;
//@property(nonatomic,strong)DataModel * model;
//-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView1;
@property (weak, nonatomic) IBOutlet UIImageView *imgView2;
@property (nonatomic,weak)DataModel * model;
@end
