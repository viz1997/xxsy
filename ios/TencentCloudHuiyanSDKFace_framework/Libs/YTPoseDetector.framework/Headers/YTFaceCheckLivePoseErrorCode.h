//
//  YTFaceCheckLivePoseErrorCode.h
//
//  Created by tidetzhang 2020/08/06.
//  Copyright © 2018 PanCheng. All rights reserved.
//

#ifndef _YTFACECHECKLIVEPOSEERRORCODE_H_
#define _YTFACECHECKLIVEPOSEERRORCODE_H_

namespace youtu
{

/// 动作类型
typedef enum : int {
    /// 眨眨眼动作
    POSETYPE_BLINK_EYE = 1,
    /// 张张嘴动作
    POSETYPE_OPEN_MOUSE = 2,

    //不建议使用的动作检测方式，安全性不如眨眼和张嘴高
    /// 点点头动作
    POSETYPE_NOD_HEAD = 3,
    /// 摇摇头
    POSETYPE_SHAKE_HEAD = 4,
    /// 静默动作
    POSETYPE_SILENCE = 5,
    POSETYPE_COUNT = POSETYPE_SILENCE + 1
} POSETYPE;

/// 动作检测返回码
typedef enum : int {
    /// 动作检测通过
    POSE_RET_POSE_COMMIT = 1,
    /// 动作检测中
    POSE_RET_POSE_DETECTING = 0,
    /// 姿态不正确
    POSE_RET_POSE_NOT_RIGHT = -1,
    /// 无人脸
    POSE_RET_NO_FACE = -2,
    /// 半边人脸
    POSE_RET_HALF_FACE = -3,
    /// 光线不合适
    POSE_RET_LIGHT_NOT_RIGHT = -4,
    /// 晃动
    POSE_RET_SHAKING = -5,
    ///点位信息不对
    POSE_SHAPE_ERROR = -6,
    /// 授权不通过
    POSE_RET_AUTH_FAILED = -1024
} YT_POSE_RET_TYPE;

/// 最佳照片检测时的返回码
typedef enum : int {
    /// 当前帧光照质量较差
    LIGHT_ERROR               = -2,
    /// 当前帧的人脸所占屏幕区域较小
    FACE_TOO_SMALL            = -3,
    /// 当前帧的人脸姿态角度过大
    POSE_ANGLE_ERROR          = -4,
    /// 当前帧的人脸嘴部姿态异常
    POSE_MOUTH_ERROR          = -5,
    /// 当前帧其他异常情况
    OHTER_ERROR               =  0,
    /// 检测正常
    SUCCESS                   =  1
} BestImgCode;

/// 动作算法类型
typedef enum : int {
    /// 推荐安全类型，光流算法
    YTPOSE_SAFETY_RECOMMAND    = 0,
    /// (点位计算)灵敏度高，但是对遮挡攻击的效果不够理想
    YTPOSE_SAFETY_LOW          = 1,
    /// (光流算法)相对安全，但是灵敏度会略微下降，让面部距离屏幕更近，可以有效提高通过率
    YTPOSE_SAFETY_HIGH         = 2,
    /// 动作类型算法数量
    YTPOSE_SAFETY_COUNT        = 3
} YTPOSE_SAFETY_LEVEL;

} // namespace youtu

#endif /* YTFaceCheckLivePose_hpp */
