//
//  FilterBarCell.h
//  OpenGLESGLSL
//
//  Created by yz on 2020/8/11.
//  Copyright © 2020 yz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterBarCell : UICollectionViewCell
@property (strong, nonatomic) NSString *title;
@property (nonatomic, assign) BOOL isSelect;
@end

NS_ASSUME_NONNULL_END
