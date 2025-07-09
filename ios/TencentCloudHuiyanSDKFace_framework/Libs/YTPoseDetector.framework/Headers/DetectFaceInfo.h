//
// Created by sunnydu on 2024/5/10.
//

#ifndef VERIFICATION_DETECTFACEINFO_H
#define VERIFICATION_DETECTFACEINFO_H
/// opencv
#ifdef __ANDROID__
#include <core.hpp>
#include <resize.hpp>
#include "cvtColor.hpp"
#else
#include <YTCv/core.hpp>
#include <YTCv/cvtColor.hpp>
#include <YTCv/resize.hpp>
#endif // __ANDROID__
/// opencv end

#include <vector>
/// 动作类型
typedef enum :int{
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
    //缓慢向左转头
    POSETYPE_TURN_LEFT = 6,
    //缓慢向右转头
    POSETYPE_TURN_RIGHT = 7,
    //由近及远
    POSETYPE_CLOSER_FAR = 8,
    //由远及近
    POSETYPE_FAR_CLOSER = 9,
    POSETYPE_COUNT = POSETYPE_SILENCE+1
}POSETYPE;

/// 动作检测返回码
typedef enum :int{
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
    POSE_RET_AUTH_FAILED = -1024,
    /// 人脸质量最佳帧不通过 (ppl层 根据归因转换tips)
    FACE_QUALITY_DELETE_FAILED = -1025,
    /// 人脸质量最佳帧获取中 (ppl tips  请保持姿态)
    FACE_QUALITY_KEEP = -1026,
    /// 人脸姿态不合格
    FACE_QUALITY_STATUS_FAILED = -1029,
    /// 人脸质量阶段 角度不符合预期
    FACE_QUALITY_STATUS_ANGLE_FAILED = -1030,
    /// 闭眼
    FACE_QUALITY_EYE_CLOSE = -1031,
    /// 张嘴
    FACE_QUALITY_MOUTH_OPEN = -1032,
    FACE_QUALITY_SHAKING = -1033,
}YT_POSE_RET_TYPE;

struct DetectFaceInfo{
    std::vector<float> shape;
    std::vector<float> visVec;
    POSETYPE postType;
    yt_tinycv::Mat3BGR rgbPtr;
    float pitch;
    float yaw;
    float roll;
    int faceDetectStatus;
    int faceQualityStatus;
    yt_tinycv::Rect2i faceRect;
    int frameW;
    int frameH;
    bool isFaceShaking;
};



#endif //VERIFICATION_DETECTFACEINFO_H
