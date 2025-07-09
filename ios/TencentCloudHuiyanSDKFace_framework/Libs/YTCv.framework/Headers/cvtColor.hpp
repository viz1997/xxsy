// fbc_cv is free software and uses the same licence as OpenCV
// Email: fengbingchun@163.com
// from: https://github.com/fengbingchun/OpenCV_Test/blob/master/src/fbc_cv/include/cvtColor.hpp
// commitID: 7c0eccf85e31c456256cc4c87d4ba752a56a18dc
#ifndef FBC_CV_CVTCOLOR_HPP_
#define FBC_CV_CVTCOLOR_HPP_

/* reference: include/opencv2/imgproc.hpp
              imgproc/src/color.cpp
*/

#include <typeinfo>
#include "mat.hpp"
#include "saturate.hpp"
#include "imgproc.hpp"
#include "core.hpp"
#ifdef __ARM_NEON__
#include "arm_neon.h"
#include <sys/time.h>
#endif

namespace yt_tinycv {
#define  FBC_DESCALE(x,n)     (((x) + (1 << ((n)-1))) >> (n))

#ifdef __ARM_NEON__
// neon intrinsic
static void NeonCvtColorRGBA2BGR(unsigned char *rgba, unsigned char *bgr, int rows, int cols) {
    int len_color = rows * cols;
    int num8x16 = len_color / 16;
    int num8len = num8x16 * 16;
    uint8x16x4_t intlv_rgba;
    uint8x16x3_t intlv_bgr;
    for (int i=0; i < num8x16; i++) {
        intlv_rgba = vld4q_u8(rgba);
        intlv_bgr.val[0] = intlv_rgba.val[2];
        intlv_bgr.val[1] = intlv_rgba.val[1];
        intlv_bgr.val[2] = intlv_rgba.val[0];
        vst3q_u8(bgr, intlv_bgr);
        rgba += 64;
        bgr += 48;
    }
    for (; num8len < len_color; num8len++) {
        bgr[0] = rgba[2];
        bgr[1] = rgba[1];
        bgr[2] = rgba[0];
        rgba += 4;
        bgr += 3;
    }
}

static void NeonCvtColorRGBA2RGB(unsigned char *rgba, unsigned char *bgr, int rows, int cols) {
    int len_color = rows * cols;
    int num8x16 = len_color / 16;
    int num8len = num8x16 * 16;
    uint8x16x4_t intlv_rgba;
    uint8x16x3_t intlv_bgr;
    for (int i=0; i < num8x16; i++) {
        intlv_rgba = vld4q_u8(rgba);
        intlv_bgr.val[0] = intlv_rgba.val[0];
        intlv_bgr.val[1] = intlv_rgba.val[1];
        intlv_bgr.val[2] = intlv_rgba.val[2];
        vst3q_u8(bgr, intlv_bgr);
        rgba += 64;
        bgr += 48;
    }
    for (; num8len < len_color; num8len++) {
        bgr[0] = rgba[0];
        bgr[1] = rgba[1];
        bgr[2] = rgba[2];
        rgba += 4;
        bgr += 3;
    }
}

static void NeonCvtColorRGB2BGR(unsigned char *rgb, unsigned char *bgr, int rows, int cols) {
    int len_color = rows * cols;
    int num8x16 = len_color / 16;
    int num8len = num8x16 * 16;
    uint8x16x3_t intlv_rgb;
    uint8x16x3_t intlv_bgr;
    for (int i=0; i < num8x16; i++) {
        intlv_rgb = vld3q_u8(rgb);
        intlv_bgr.val[0] = intlv_rgb.val[2];
        intlv_bgr.val[1] = intlv_rgb.val[1];
        intlv_bgr.val[2] = intlv_rgb.val[0];
        vst3q_u8(bgr, intlv_bgr);
        rgb += 48;
        bgr += 48;
    }
    for (; num8len < len_color; num8len++) {
        bgr[0] = rgb[2];
        bgr[1] = rgb[1];
        bgr[2] = rgb[0];
        rgb += 3;
        bgr += 3;
    }
}
#endif

template<typename _Tp, int chs1, int chs2> static int CvtColorLoop_RGB2RGB(const Mat_<_Tp, chs1>& src, Mat_<_Tp, chs2>& dst, int bidx);
template<typename _Tp, int chs1, int chs2> static int CvtColorLoop_RGB2Gray(const Mat_<_Tp, chs1>& src, Mat_<_Tp, chs2>& dst, int bidx);
template<typename _Tp, int chs1, int chs2> static int CvtColorLoop_RGB2YCrCb(const Mat_<_Tp, chs1>& src, Mat_<_Tp, chs2>& dst, int bidx, const float* coeffs_f, const int* coeffs_i);
template<typename _Tp, int chs1, int chs2, int bIdx, int uIdx> static void cvtRGBtoYUV420p(const Mat_<_Tp, chs1>& src, Mat_<_Tp, chs2>& dst);

#undef R2Y
#undef G2Y
#undef B2Y

enum {
	yuv_shift = 14,
	xyz_shift = 12,
	R2Y = 4899,
	G2Y = 9617,
	B2Y = 1868,
	BLOCK_SIZE = 256
};

// Converts an image from one color space to another
// support type: uchar/ushort/float
template<typename _Tp, int chs1, int chs2>
int cvtColor(const Mat_<_Tp, chs1>& src, Mat_<_Tp, chs2>& dst, int code)
{
	FBC_Assert(src.cols > 0 &&  src.rows > 0 && dst.cols > 0 && dst.rows > 0);
	FBC_Assert(src.cols == dst.cols);
	FBC_Assert(src.data != NULL && dst.data != NULL);
	FBC_Assert(typeid(uchar).name() == typeid(_Tp).name() ||
		typeid(ushort).name() == typeid(_Tp).name() ||
		typeid(float).name() == typeid(_Tp).name());
	FBC_Assert((sizeof(_Tp) == 1) || sizeof(_Tp) == 2 || sizeof(_Tp) == 4); // uchar || ushort || float

	int scn = src.channels;
	int dcn = dst.channels; // number of channels in the destination image
	Size sz = src.size();
	Size dz = dst.size();
	int bidx;
    
#ifdef __ARM_NEON__
    if (CV_RGBA2BGR == code || CV_BGRA2RGB == code) {
//        timeval tv_begin, tv_end;
//        gettimeofday(&tv_begin, NULL);
        NeonCvtColorRGBA2BGR(src.data, dst.data, dst.rows, dst.cols);
//        gettimeofday(&tv_end, NULL);
//        float elapsed = ((tv_end.tv_sec - tv_begin.tv_sec) * 1000000.0f + tv_end.tv_usec - tv_begin.tv_usec) / 1000.0f;
//        printf("lgy neon NeonCvtColorRGBA2BGR code : %d, %f ms\n", code, elapsed);
        return 0;
    }
    
    if (CV_RGBA2RGB == code || CV_BGRA2BGR == code) {
        NeonCvtColorRGBA2RGB(src.data, dst.data, dst.rows, dst.cols);
        return 0;
    }

    if (CV_BGR2RGB == code || CV_RGB2BGR == code) {
        NeonCvtColorRGB2BGR(src.data, dst.data, dst.rows, dst.cols);
        return 0;
    }
#endif

	switch (code) {
		case CV_BGR2BGRA: case CV_RGB2BGRA: case CV_BGRA2BGR:
		case CV_RGBA2BGR: case CV_RGB2BGR: case CV_BGRA2RGBA: {
			FBC_Assert(scn == 3 || scn == 4);
			dcn = code == CV_BGR2BGRA || code == CV_RGB2BGRA || code == CV_BGRA2RGBA ? 4 : 3;
			FBC_Assert(dst.channels == dcn);
			bidx = code == CV_BGR2BGRA || code == CV_BGRA2BGR ? 0 : 2;

			CvtColorLoop_RGB2RGB(src, dst, bidx); // uchar/ushort/float
			break;
		}
		case CV_BGR2GRAY: case CV_BGRA2GRAY: case CV_RGB2GRAY: case CV_RGBA2GRAY: {
			FBC_Assert(scn == 3 || scn == 4);
			FBC_Assert(dst.channels == 1);
			bidx = code == CV_BGR2GRAY || code == CV_BGRA2GRAY ? 0 : 2;

			CvtColorLoop_RGB2Gray(src, dst, bidx);
			break;
		}
		case CV_BGR2YUV: case CV_RGB2YUV:{
			FBC_Assert(scn == 3 || scn == 4);
			bidx = code == CV_BGR2YUV ? 0 : 2;
			static const float yuv_f[] = { 0.114f, 0.587f, 0.299f, 0.492f, 0.877f };
			static const int yuv_i[] = { B2Y, G2Y, R2Y, 8061, 14369 };
			CvtColorLoop_RGB2YCrCb(src, dst, bidx, yuv_f, yuv_i);
			break;
		}
		case CV_RGB2YUV_YV12: case CV_BGR2YUV_YV12: case CV_RGBA2YUV_YV12: case CV_BGRA2YUV_YV12:
		case CV_RGB2YUV_IYUV: case CV_BGR2YUV_IYUV: case CV_RGBA2YUV_IYUV: case CV_BGRA2YUV_IYUV: {
			const int bIdx = (code == CV_BGR2YUV_IYUV || code == CV_BGRA2YUV_IYUV || code == CV_BGR2YUV_YV12 || code == CV_BGRA2YUV_YV12) ? 0 : 2;
			const int uIdx = (code == CV_BGR2YUV_IYUV || code == CV_BGRA2YUV_IYUV || code == CV_RGB2YUV_IYUV || code == CV_RGBA2YUV_IYUV) ? 1 : 2;

			FBC_Assert(scn == 3 || scn == 4);
			FBC_Assert(sizeof(_Tp) == 1);
			FBC_Assert(dcn == 1);
			FBC_Assert(sz.width % 2 == 0 && sz.height % 2 == 0);

			//Size dstSz(sz.width, sz.height / 2 * 3);
			FBC_Assert((dz.width == sz.width) && (sz.height / 2 * 3 == dz.height));

			switch (bIdx + uIdx * 10) {
				case 10: cvtRGBtoYUV420p<_Tp, chs1, chs2, 0, 1>(src, dst); break;
				case 12: cvtRGBtoYUV420p<_Tp, chs1, chs2, 2, 1>(src, dst); break;
				case 20: cvtRGBtoYUV420p<_Tp, chs1, chs2, 0, 2>(src, dst); break;
				case 22: cvtRGBtoYUV420p<_Tp, chs1, chs2, 2, 2>(src, dst); break;
				default: FBC_Error("Unknown/unsupported color conversion code"); break;
			};

			break;
		}
		default:
			FBC_Error("Unknown/unsupported color conversion code");
	}

	return 0;
}

// computes cubic spline coefficients for a function: (xi=i, yi=f[i]), i=0..n
template<typename _Tp> static void splineBuild(const _Tp* f, int n, _Tp* tab)
{
	_Tp cn = 0;
	int i;
	tab[0] = tab[1] = (_Tp)0;

	for (i = 1; i < n - 1; i++) {
		_Tp t = 3 * (f[i + 1] - 2 * f[i] + f[i - 1]);
		_Tp l = 1 / (4 - tab[(i - 1) * 4]);
		tab[i * 4] = l; tab[i * 4 + 1] = (t - tab[(i - 1) * 4 + 1])*l;
	}

	for (i = n - 1; i >= 0; i--) {
		_Tp c = tab[i * 4 + 1] - tab[i * 4] * cn;
		_Tp b = f[i + 1] - f[i] - (cn + c * 2)*(_Tp)0.3333333333333333;
		_Tp d = (cn - c)*(_Tp)0.3333333333333333;
		tab[i * 4] = f[i]; tab[i * 4 + 1] = b;
		tab[i * 4 + 2] = c; tab[i * 4 + 3] = d;
		cn = c;
	}
}

// interpolates value of a function at x, 0 <= x <= n using a cubic spline.
template<typename _Tp> static inline _Tp splineInterpolate(_Tp x, const _Tp* tab, int n)
{
	// don't touch this function without urgent need - some versions of gcc fail to inline it correctly
	int ix = std::min(std::max(int(x), 0), n - 1);
	x -= ix;
	tab += ix * 4;
	return ((tab[3] * x + tab[2])*x + tab[1])*x + tab[0];
}

template<typename _Tp> struct ColorChannel
{
	typedef float worktype_f;
	static _Tp max() { return std::numeric_limits<_Tp>::max(); }
	static _Tp half() { return (_Tp)(max() / 2 + 1); }
};

template<> struct ColorChannel<float>
{
	typedef float worktype_f;
	static float max() { return 1.f; }
	static float half() { return 0.5f; }
};

template<typename _Tp> struct RGB2Gray
{
	typedef _Tp channel_type;

	RGB2Gray(int _srccn, int blueIdx, const float* _coeffs) : srccn(_srccn)
	{
		static const float coeffs0[] = { 0.299f, 0.587f, 0.114f };
		memcpy(coeffs, _coeffs ? _coeffs : coeffs0, 3 * sizeof(coeffs[0]));
		if (blueIdx == 0)
			std::swap(coeffs[0], coeffs[2]);
	}

	void operator()(const _Tp* src, _Tp* dst, int n) const
	{
		int scn = srccn;
		float cb = coeffs[0], cg = coeffs[1], cr = coeffs[2];
		for (int i = 0; i < n; i++, src += scn)
			dst[i] = saturate_cast<_Tp>(src[0] * cb + src[1] * cg + src[2] * cr);
	}
	int srccn;
	float coeffs[3];
};

template<> struct RGB2Gray<uchar>
{
	typedef uchar channel_type;

	RGB2Gray(int _srccn, int blueIdx, const int* coeffs) : srccn(_srccn)
	{
		const int coeffs0[] = { R2Y, G2Y, B2Y };
		if (!coeffs) coeffs = coeffs0;

		int b = 0, g = 0, r = (1 << (yuv_shift - 1));
		int db = coeffs[blueIdx ^ 2], dg = coeffs[1], dr = coeffs[blueIdx];

		for (int i = 0; i < 256; i++, b += db, g += dg, r += dr) {
			tab[i] = b;
			tab[i + 256] = g;
			tab[i + 512] = r;
		}
	}
	void operator()(const uchar* src, uchar* dst, int n) const
	{
		int scn = srccn;
		const int* _tab = tab;
		for (int i = 0; i < n; i++, src += scn)
			dst[i] = (uchar)((_tab[src[0]] + _tab[src[1] + 256] + _tab[src[2] + 512]) >> yuv_shift);
	}
	int srccn;
	int tab[256 * 3];
};

template<> struct RGB2Gray<ushort>
{
	typedef ushort channel_type;

	RGB2Gray(int _srccn, int blueIdx, const int* _coeffs) : srccn(_srccn)
	{
		static const int coeffs0[] = { R2Y, G2Y, B2Y };
		memcpy(coeffs, _coeffs ? _coeffs : coeffs0, 3 * sizeof(coeffs[0]));
		if (blueIdx == 0)
			std::swap(coeffs[0], coeffs[2]);
	}

	void operator()(const ushort* src, ushort* dst, int n) const
	{
		int scn = srccn, cb = coeffs[0], cg = coeffs[1], cr = coeffs[2];
		for (int i = 0; i < n; i++, src += scn)
			dst[i] = (ushort)FBC_DESCALE((unsigned)(src[0] * cb + src[1] * cg + src[2] * cr), yuv_shift);
	}
	int srccn;
	int coeffs[3];
};

template<typename _Tp> struct RGB2YCrCb_f{
	typedef _Tp channel_type;
	RGB2YCrCb_f(int _srccn, int _blueIdx, const float* _coeffs) : srccn(_srccn), blueIdx(_blueIdx)
	{
		static const float coeffs0[] = { 0.299f, 0.587f, 0.114f, 0.713f, 0.564f };
		memcpy(coeffs, _coeffs ? _coeffs : coeffs0, 5 * sizeof(coeffs[0]));
		if (blueIdx == 0) std::swap(coeffs[0], coeffs[2]);
	}
	void operator()(const _Tp* src, _Tp* dst, int n) const
	{
		int scn = srccn, bidx = blueIdx;
		const _Tp delta = ColorChannel<_Tp>::half();
		float C0 = coeffs[0], C1 = coeffs[1], C2 = coeffs[2], C3 = coeffs[3], C4 = coeffs[4];
		n *= 3;
		for (int i = 0; i < n; i += 3, src += scn) {
			_Tp Y = saturate_cast<_Tp>(src[0] * C0 + src[1] * C1 + src[2] * C2);
			_Tp Cr = saturate_cast<_Tp>((src[bidx ^ 2] - Y)*C3 + delta);
			_Tp Cb = saturate_cast<_Tp>((src[bidx] - Y)*C4 + delta);
			dst[i] = Y; dst[i + 1] = Cr; dst[i + 2] = Cb;
		}
	}
	int srccn, blueIdx;
	float coeffs[5];
};
template<typename _Tp> struct RGB2YCrCb_i{
	typedef _Tp channel_type;
	RGB2YCrCb_i(int _srccn, int _blueIdx, const int* _coeffs) : srccn(_srccn), blueIdx(_blueIdx)
	{
		static const int coeffs0[] = { R2Y, G2Y, B2Y, 11682, 9241 };
		memcpy(coeffs, _coeffs ? _coeffs : coeffs0, 5 * sizeof(coeffs[0]));
		if (blueIdx == 0) std::swap(coeffs[0], coeffs[2]);
	}
	void operator()(const _Tp* src, _Tp* dst, int n) const
	{
		int scn = srccn, bidx = blueIdx;
		int C0 = coeffs[0], C1 = coeffs[1], C2 = coeffs[2], C3 = coeffs[3], C4 = coeffs[4];
		int delta = ColorChannel<_Tp>::half()*(1 << yuv_shift);
		n *= 3;
		for (int i = 0; i < n; i += 3, src += scn) {
			int Y = FBC_DESCALE(src[0] * C0 + src[1] * C1 + src[2] * C2, yuv_shift);
			int Cr = FBC_DESCALE((src[bidx ^ 2] - Y)*C3 + delta, yuv_shift);
			int Cb = FBC_DESCALE((src[bidx] - Y)*C4 + delta, yuv_shift);
			dst[i] = saturate_cast<_Tp>(Y);
			dst[i + 1] = saturate_cast<_Tp>(Cr);
			dst[i + 2] = saturate_cast<_Tp>(Cb);
		}
	}
	int srccn, blueIdx;
	int coeffs[5];
};

const int ITUR_BT_601_CY = 1220542;
const int ITUR_BT_601_CUB = 2116026;
const int ITUR_BT_601_CUG = -409993;
const int ITUR_BT_601_CVG = -852492;
const int ITUR_BT_601_CVR = 1673527;
const int ITUR_BT_601_SHIFT = 20;
const int ITUR_BT_601_CRY = 269484;
const int ITUR_BT_601_CGY = 528482;
const int ITUR_BT_601_CBY = 102760;
const int ITUR_BT_601_CRU = -155188;
const int ITUR_BT_601_CGU = -305135;
const int ITUR_BT_601_CBU = 460324;
const int ITUR_BT_601_CGV = -385875;
const int ITUR_BT_601_CBV = -74448;

template<typename _Tp, int chs1, int chs2, int bIdx>
struct RGB888toYUV420pInvoker{
	RGB888toYUV420pInvoker(const Mat_<_Tp, chs1>& src, Mat_<_Tp, chs2>* dst, const int uIdx)
	: src_(src), dst_(dst), uIdx_(uIdx) { }
	void operator()(const Range& rowRange) const
	{
		const int w = src_.cols;
		const int h = src_.rows;
		const int cn = src_.channels;
		for (int i = rowRange.start; i < rowRange.end; i++) {
			const uchar* row0 = src_.ptr(2 * i);
			const uchar* row1 = src_.ptr(2 * i + 1);
			uchar* y = (uchar*)dst_->ptr(2 * i);
			uchar* u = (uchar*)dst_->ptr(h + i / 2) + (i % 2) * (w / 2);
			uchar* v = (uchar*)dst_->ptr(h + (i + h / 2) / 2) + ((i + h / 2) % 2) * (w / 2);
			if (uIdx_ == 2) std::swap(u, v);
			for (int j = 0, k = 0; j < w * cn; j += 2 * cn, k++) {
				int r00 = row0[2 - bIdx + j];      int g00 = row0[1 + j];      int b00 = row0[bIdx + j];
				int r01 = row0[2 - bIdx + cn + j]; int g01 = row0[1 + cn + j]; int b01 = row0[bIdx + cn + j];
				int r10 = row1[2 - bIdx + j];      int g10 = row1[1 + j];      int b10 = row1[bIdx + j];
				int r11 = row1[2 - bIdx + cn + j]; int g11 = row1[1 + cn + j]; int b11 = row1[bIdx + cn + j];
				const int shifted16 = (16 << ITUR_BT_601_SHIFT);
				const int halfShift = (1 << (ITUR_BT_601_SHIFT - 1));
				int y00 = ITUR_BT_601_CRY * r00 + ITUR_BT_601_CGY * g00 + ITUR_BT_601_CBY * b00 + halfShift + shifted16;
				int y01 = ITUR_BT_601_CRY * r01 + ITUR_BT_601_CGY * g01 + ITUR_BT_601_CBY * b01 + halfShift + shifted16;
				int y10 = ITUR_BT_601_CRY * r10 + ITUR_BT_601_CGY * g10 + ITUR_BT_601_CBY * b10 + halfShift + shifted16;
				int y11 = ITUR_BT_601_CRY * r11 + ITUR_BT_601_CGY * g11 + ITUR_BT_601_CBY * b11 + halfShift + shifted16;
				y[2 * k + 0] = saturate_cast<uchar>(y00 >> ITUR_BT_601_SHIFT);
				y[2 * k + 1] = saturate_cast<uchar>(y01 >> ITUR_BT_601_SHIFT);
				y[2 * k + dst_->step + 0] = saturate_cast<uchar>(y10 >> ITUR_BT_601_SHIFT);
				y[2 * k + dst_->step + 1] = saturate_cast<uchar>(y11 >> ITUR_BT_601_SHIFT);
				const int shifted128 = (128 << ITUR_BT_601_SHIFT);
				int u00 = ITUR_BT_601_CRU * r00 + ITUR_BT_601_CGU * g00 + ITUR_BT_601_CBU * b00 + halfShift + shifted128;
				int v00 = ITUR_BT_601_CBU * r00 + ITUR_BT_601_CGV * g00 + ITUR_BT_601_CBV * b00 + halfShift + shifted128;
				u[k] = saturate_cast<uchar>(u00 >> ITUR_BT_601_SHIFT);
				v[k] = saturate_cast<uchar>(v00 >> ITUR_BT_601_SHIFT);
			}
		}
	}
private:
	RGB888toYUV420pInvoker& operator=(const RGB888toYUV420pInvoker&);
	const Mat_<_Tp, chs1>& src_;
	Mat_<_Tp, chs2>* const dst_;
	const int uIdx_;
};


template<typename _Tp, int chs1, int chs2>
static int CvtColorLoop_RGB2RGB(const Mat_<_Tp, chs1>& src, Mat_<_Tp, chs2>& dst, int bidx)
{
	Range range(0, src.rows);

	const uchar* yS_ = src.ptr(range.start);
	uchar* yD_ = (uchar*)dst.ptr(range.start);
	int scn = src.channels, dcn = dst.channels;

	for (int h = range.start; h < range.end; ++h, yS_ += src.step, yD_ += dst.step) {
		int n = src.cols;
		const _Tp* yS = (const _Tp*)yS_;
		_Tp* yD = (_Tp*)yD_;

		if (dcn == 3) {
			n *= 3;
			for (int i = 0; i < n; i += 3, yS += scn) {
				_Tp t0 = yS[bidx], t1 = yS[1], t2 = yS[bidx ^ 2];
				yD[i] = t0; yD[i + 1] = t1; yD[i + 2] = t2;
			}
		} else if (scn == 3) {
			n *= 3;
			_Tp alpha = ColorChannel<_Tp>::max(); // Note: _Tp = float: alpha = 1.0f
			for (int i = 0; i < n; i += 3, yD += 4) {
				_Tp t0 = yS[i], t1 = yS[i + 1], t2 = yS[i + 2];
				yD[bidx] = t0; yD[1] = t1; yD[bidx ^ 2] = t2; yD[3] = alpha;
			}
		} else {
			n *= 4;
			for (int i = 0; i < n; i += 4) {
				_Tp t0 = yS[i], t1 = yS[i + 1], t2 = yS[i + 2], t3 = yS[i + 3];
				yD[i] = t2; yD[i + 1] = t1; yD[i + 2] = t0; yD[i + 3] = t3;
			}
		}
	}

	return 0;
}

template<typename _Tp, int chs1, int chs2>
static int CvtColorLoop_RGB2Gray(const Mat_<_Tp, chs1>& src, Mat_<_Tp, chs2>& dst, int bidx)
{
	Range range(0, src.rows);
	const uchar* yS = src.ptr(range.start);
	uchar* yD = (uchar*)dst.ptr(range.start);
	int scn = src.channels, dcn = dst.channels;

	RGB2Gray<_Tp> rgb2gray(scn, bidx, 0);

	for (int i = range.start; i < range.end; ++i, yS += src.step, yD += dst.step) {
		rgb2gray((const _Tp*)yS, (_Tp*)yD, src.cols);
	}

	return 0;
}

template<typename _Tp, int chs1, int chs2>
static int CvtColorLoop_RGB2YCrCb(const Mat_<_Tp, chs1>& src, Mat_<_Tp, chs2>& dst, int bidx, const float* coeffs_f, const int* coeffs_i)
{
	Range range(0, src.rows);
	const uchar* yS = src.ptr(range.start);
	uchar* yD = (uchar*)dst.ptr(range.start);
	int scn = src.channels, dcn = dst.channels;
	if (sizeof(_Tp) == 4) {
		RGB2YCrCb_f<_Tp> rgb2ycrcb(scn, bidx, coeffs_f);
		for (int i = range.start; i < range.end; ++i, yS += src.step, yD += dst.step) {
			rgb2ycrcb((const _Tp*)yS, (_Tp*)yD, src.cols);
		}
	} else {
		if (sizeof(_Tp) == 1) {
			RGB2YCrCb_i<uchar> rgb2ycrcb(scn, bidx, coeffs_i);
			for (int i = range.start; i < range.end; ++i, yS += src.step, yD += dst.step) {
				rgb2ycrcb((const uchar*)yS, (uchar*)yD, src.cols);
			}
		} else {
			RGB2YCrCb_i<ushort> rgb2ycrcb(scn, bidx, coeffs_i);
			for (int i = range.start; i < range.end; ++i, yS += src.step, yD += dst.step) {
				rgb2ycrcb((const ushort*)yS, (ushort*)yD, src.cols);
			}
		}
	}
	return 0;
}

template<typename _Tp, int chs1, int chs2, int bIdx, int uIdx>
static void cvtRGBtoYUV420p(const Mat_<_Tp, chs1>& src, Mat_<_Tp, chs2>& dst)
{
	RGB888toYUV420pInvoker<_Tp, chs1, chs2, bIdx> colorConverter(src, &dst, uIdx);
	colorConverter(Range(0, src.rows / 2));
}


} // namespace yt_tinycv
#endif // FBC_CV_CVTCOLOR_HPP_
