//
//  YTFaceCheckLivePose.hpp
//  YTPoseDetector
//
//  Created by Cheng Pan on 3/27/18.
//  Copyright © 2018 PanCheng. All rights reserved.
//

#ifndef YTFaceCheckLivePose_hpp
#define YTFaceCheckLivePose_hpp

#include <stdint.h>
#include <stdio.h>
#include <string>
#include <vector>
#include <sstream>
#include <math.h>
#include "Far2NearData.h"
#include "YTFaceQualityDetect.h"
#include "DetectFaceInfo.h"
#include "PoseUtils.h"
#ifdef __ANDROID__
#include <core.hpp>
#include <resize.hpp>
#include "cvtColor.hpp"


#else
#include <YTCv/core.hpp>
#include <YTCv/cvtColor.hpp>
#include <YTCv/resize.hpp>
#endif // __ANDROID__


#ifdef YTFACETRACK_NAMESPACE
#endif
#ifdef __ANDROID__
#define FACEDETECT_EXPORT
#else
#define FACEDETECT_EXPORT __attribute__((visibility("default")))
#endif
#define YT_FACEPOSE_VERSION "3.7.5"
#define P_FRAMEWORK_VERSION "@FRAMEWORK_VERSION"
namespace youtu {
typedef int (*YtFacePoseSDKLogCallback)(void *caller, int level, std::string message);
typedef void (*PlatformJpegEncoderCallback)(void *context, unsigned char *rgb, int rows, int cols, std::string &jpegData);
class YTPoseLiveDetector;

/// 最佳照片检测时的返回码
typedef enum :int{
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
}BestImgCode;

/// 动作算法类型
typedef enum :int {
    /// 推荐安全类型，光流算法
    YTPOSE_SAFETY_RECOMMAND    = 0,
    /// (点位计算)灵敏度高，但是对遮挡攻击的效果不够理想
    YTPOSE_SAFETY_LOW          = 1,
    /// (光流算法)相对安全，但是灵敏度会略微下降，让面部距离屏幕更近，可以有效提高通过率
    YTPOSE_SAFETY_HIGH         = 2,
    /// 动作类型算法数量
    YTPOSE_SAFETY_COUNT        = 3
}YTPOSE_SAFETY_LEVEL;

struct YTPoseRect
{
    int x;
    int y;
    int width;
    int height;

    YTPoseRect() :x(0), y(0), width(0), height(0){}
    YTPoseRect(int x_, int y_, int width_, int height_) :x(x_), y(y_), width(width_), height(height_){}
};

struct YTSize
{
    int width;
    int height;

    YTSize() :width(0), height(0){}
    YTSize(int width_, int height_) :width(width_), height(height_){}
};


struct YTPosePoint2f
{
    float x;
    float y;
    YTPosePoint2f() :x(0), y(0){}
    YTPosePoint2f(int x_, int y_) :x(x_), y(y_){}

    YTPosePoint2f operator -(const YTPosePoint2f& rp){
        return YTPosePoint2f(x - rp.x, y - rp.y);
    }
};

inline float Norm(YTPosePoint2f p)
{
    double x = p.x;
    double y = p.y;
    return sqrt(x * x + y * y);
}



/// 动作检测对象类
class FACEDETECT_EXPORT FaceCheckLivePose
{
public:
    /// 动作检测构造接口
    /// @param _frameNum 缓存视频帧数（推荐20帧）
    FaceCheckLivePose(int _frameNum=20);
    /// 动作检测析构接口
    ~FaceCheckLivePose();
    /// 获取版本信息
    /// @note 返回当前版本信息
    static std::string getVersion();
    /// 重置接口
    ///@note 每次开始检测动作的时候请调用reset；检测不到人脸的时候也应该调用reset，以保障动作过程中没有发生人脸切换
    /// 获取完最优图和视频帧数据后也请调用reset接口
    void reset();
    
    /// 动作安全等级设置接口
    /// @param level 参考YTPOSE_SAFETY_LEVEL 目标安全等级
    void setSafetyLevel(YTPOSE_SAFETY_LEVEL level);
    /// 动作安全等级获取接口
    /// @return 返回当前动作安全等级
    YTPOSE_SAFETY_LEVEL getSafetyLevel();
    
    /// 动作检测接口
    /// @param shapeInput 输入人脸框
    /// @param visVec 输入关键点置信度
    /// @param poseType 输入目标动作
    /// @param rgb 输入帧信息rgb
    /// @param yuv 输入帧信息yuv（仅android使用，其他情况请填充空mat）
    /// @param pitch 输入人脸俯仰角度
    /// @param yaw 输入人脸左右角度
    /// @param roll 输入人脸旋转角度
    /// @return 返回YT_POSE_RET_TYPE 对应的错误码信息
    /**
    return -1 姿态不正确
    -2 当前没有人脸
    -3 当前只有半张脸
    -4 光线不合适
    -5 当前晃动较大
    -1024 授权检测不过
    **/
    int detect_liveness(DetectFaceInfo& detectFaceInfo);
    void registerSDKLogger(int level, YtFacePoseSDKLogCallback listener);
    //最优图相关接口    
    /// 获取最优图
    /// @return 返回对应最优图
    yt_tinycv::Mat3BGR get_BestImgMat();
    /// 获取最优图
    /// @param shape 人脸信息
    /// @return 返回对应最优图
    yt_tinycv::Mat3BGR get_BestImgMat(std::vector<float> & shape);
    /// 检测记录完成通知
    /// @return 返回是否可以获取序列帧视频和最优图
    bool get_RecordingDone();


    /// 获取当前已经存储的视频流
    /// @return 返回序列帧 yuv格式
    std::vector<yt_tinycv::Mat3BGR> get_bgrFrameList();
    // 动作+反光合并协议相关接口
    /// 获取动作幅度最大图
    /// @param bestImg 输出动作最大的图
    /// @param bestShape 输出动作最大的点位信息
    /// @param eyeImg 输出动作最大的eye部图
    /// @param eyeShape 输出动作最大的eye部点位信息
    /// @param mouthImg 输出动作最大的mouth部图
    /// @param mouthImg 输出动作最大的mouth部点位信息
    void get_PoseImgMat(yt_tinycv::Mat3BGR &bestImg, std::vector<float> &bestShape,
                        yt_tinycv::Mat3BGR &eyeImg, std::vector<float> &eyeShape,
                        yt_tinycv::Mat3BGR &mouthImg, std::vector<float> &mouthShape
                                      );
    int get_actionVideoShortenStrategy();
    //主要动作执行完成，可以启动下一个步骤（目前主要用于动作+反光方案）
    /// 检测是否可以进入反光
    /// @return 返回是否可以进入反光状态
    bool get_CanReflect();
    /// 更新内部检测参数
    /// @param key 参数key
    /// @param value 参数值
    int updateParam(const std::string &key, const std::string &value);    
    std::string checksum(const std::string data);

    void setColorData(std::string cp, std::string clientVersion, std::string actStr);

    void setChecksumJpg(std::string best, std::string eye, std::string mouth);

    std::string getSelectDataChecksum(std::string selectDataStr, std::string actionVideo);

    yt_tinycv::Mat3BGR get_MaxActionEyeImgMat(std::vector<float> & shape);
    yt_tinycv::Mat3BGR get_MaxActionMouthImgMat(std::vector<float> & shape);

    bool isFrameListNull();
    void initFar2NearParam(int width,int height,int count,float min_r,float max_r);
    FaceFrameList GetFaceDistanceDetectData();
    std::vector<yt_tinycv::Rect2i> GetFaceDistanceProcessRect();
    std::string getFaceDetectDistanceRectParam();
    std::vector<int> GetLargeFace();
    std::vector<int> GetSmallFace();
    float GetFar2NearRectChangeScore();
private:
    YTPoseLiveDetector* livenessdetector;
    YTFaceQualityDetect* faceQualityDetect;
    PoseUtils* poseUtils;
    std::string anchorWidths;
    std::string checksumBest;
    std::string checksumEye;
    std::string checksumMouth;
    std::string checksumActionVideo;
};
/// 推荐对外使用类型
class FACEDETECT_EXPORT YTFaceCheckLivePose:public FaceCheckLivePose{};

}

#endif /* YTFaceCheckLivePose_hpp */
