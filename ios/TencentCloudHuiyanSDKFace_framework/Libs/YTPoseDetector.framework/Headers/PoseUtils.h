#ifndef PoseUtils_h
#define PoseUtils_h

#include <stdint.h>
#include <stdio.h>
#include <string>
#include <vector>
#include <sstream>
#include <math.h>



typedef struct _CAPTCHA_V2_ {
    int fixedInterval;          // 4 or 1
    int unit;                   // ios: 70, andorid 120
    std::vector<int> intervals; // 3 - 6
    int rand_shift;             // 0 - 3
    int rand_inv;               // -1 1
    int version_flag;           // 471418
    int section_num;            // section_num / intervals_num
    int action;                 // -1
    int unit_v2;
    int live_mode;               // 0 is close, 1 only open reflective, 2 only open action, 3. both open.
    int64_t time_stamp_tv_sec;
    int64_t time_stamp_tv_usec;
    std::vector<int> colors;     // total
    std::vector<int> intervals2; // 2 - ?
    std::vector<int> reserved_int; // size is 16, default is 5
    std::string reserved;
} CAPTCHA_V2;

class PoseUtils{
public:
    PoseUtils();
    /**
    * @brief 生成一串数字 用于checksum计算
    * 
    * @param CP_string 
    * @return uint64_t 
    */
    uint64_t yt_parseCP(const std::string CP_string);
    void setColorData(std::string cpStr, std::string clientVersionStr, std::string actStr);
    std::string checksum(const std::string data);
    std::string getSelectDataChecksum(std::string selectDataStr, std::string actVideochecksum,std::string checksumBest,std::string checksumMouth,std::string checksumEye);
private:
    std::string clientVersionStr;
    std::string actStr;
    uint64_t timestamp;
};
#endif /* PoseUtils_h */