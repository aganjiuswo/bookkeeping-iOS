//
//  BCHUDContentCell.h
//  bookkeeping
//
//  Created by 郑业强 on 2018/12/30.
//  Copyright © 2018年 kk. All rights reserved.
//

#import "BaseTableCell.h"
#import "HomeListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHUDContentCell : BaseTableCell

@property (nonatomic, strong) HomeListModel *model;

@end

NS_ASSUME_NONNULL_END
