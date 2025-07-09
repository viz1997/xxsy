//
// Created by sunnydu on 2024/5/9.
//

#ifndef VERIFICATION_YTFACEQUALITYDETECT_H
#define VERIFICATION_YTFACEQUALITYDETECT_H
#include "DetectFaceInfo.h"
#ifdef __ANDROID__
#include <core.hpp>
#include <resize.hpp>
#include "cvtColor.hpp"

#else
#include <YTCv/core.hpp>
#include <YTCv/cvtColor.hpp>
#include <YTCv/resize.hpp>
#endif // __ANDROID__
#include <vector>
class YTFaceQualityDetect {
public:
    int  needFaceQualityImage = false;
    float stableRoiThreshold = 0.98f;//模糊判断
    float continuousShelterNumThreshold = 5;
    int   continuousQualityNumThreshold = 10;
//    float faceMaxHeightThreshold = 0.95f;
//    float faceRealMinHeightThreshold = 0.4f;
    float secondaryYawThreshold = 18;
    float secondaryPitchThreshold = 18;
    float secondaryRollThreshold = 18;
    float closeMouthThreshold = 0.4f;
    float closeEyeLeftThreshold = 0.25f;//左睁眼阈值
    float closeEyeRightThreshold = 0.25f;//右睁眼阈值
    //人脸质量最佳帧
    bool isGetImageMat = false;
    yt_tinycv::Mat3BGR qualityImageMat;
    std::vector<float> qualityShape;
    int continuousCount = 0;
    int continuousShelterCount = 0;
    /**
     * 清空连续帧计数
     */
    void resetContinuousCount();
    /**
     * 遮挡累计检测
     */
    void shelterDetect();
    /**
     * 计数器+1，然后判断是否满足条件
     */
    int faceQualityIsPass(DetectFaceInfo& detectFaceInfo);
private:
    yt_tinycv::Rect2i previousFaceRect = yt_tinycv::Rect2i(0,0,0,0);
    /**
     * 内置二级角度检测
     */
    bool faceAngleForceCheck(DetectFaceInfo& detectFaceInfo);
    /**
  * 检测脸部长度占比，脸部长度占比在图像长度的预设百分比(faceHeightThreshold) 视为通过，否则不通过
  * faceHeightThreshold 默认为0，不对人脸大小做限制
  *
  * @return 1 太远
  * 2 太近
  * 0 合适
  */
    int isFaceHeightStandard(DetectFaceInfo& detectFaceInfo);

    /**
     * 闭眼判断
     * @param shape
     * @return
     */
    bool isEyeOpen(DetectFaceInfo& detectFaceInfo);

    /**
     * 张嘴检测
     * @param detectFaceInfo
     * @return
     */
    bool isMouthClose(DetectFaceInfo& detectFaceInfo);

    /**
     * 计算人脸框差值
     * @param rect1
     * @param outRect
     */
    void getIntersectionRect(const yt_tinycv::Rect2i& rect1,yt_tinycv::Rect2i& outRect);

    /**
     * 遮挡判断
     * @param rect
     * @return
     */
    bool detectScreenShaking(const yt_tinycv::Rect2i&  rect);


};


#endif //VERIFICATION_YTFACEQUALITYDETECT_H
