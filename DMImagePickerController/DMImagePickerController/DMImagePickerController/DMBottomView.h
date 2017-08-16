//
//  DMBottomView.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DMBottomViewDelegate <NSObject>

@optional

- (void)DMBottomViewDidClickedOriginalPicture:(UIButton *)originalPictureBtn;

@end

@interface DMBottomView : UIView

/**设置原图选中状态 YES:选中*/
@property (nonatomic, assign)BOOL selectedOriginalPicture;

/**Yes:隐藏预览按钮，显示编辑按钮*/
@property (nonatomic, assign)BOOL showEditButton;

/**已选照片张数*/
@property (nonatomic, assign)NSInteger count;

/**当已选照片张数为零,发送按钮是否可以点击   YES:可以点击*/
@property (nonatomic, assign)BOOL sendEnable;

@property (nonatomic, assign)id<DMBottomViewDelegate> delegate;

@end
