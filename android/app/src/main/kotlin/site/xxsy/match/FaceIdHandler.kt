package site.xxsy.match

import android.content.Context
import android.os.Bundle
import android.util.Log
import com.tencent.cloud.huiyansdkface.facelight.api.WbCloudFaceVerifySdk
import com.tencent.cloud.huiyansdkface.facelight.api.result.WbFaceError
import com.tencent.cloud.huiyansdkface.facelight.api.result.WbFaceVerifyResult
import com.tencent.cloud.huiyansdkface.facelight.api.listeners.*
import com.tencent.cloud.huiyansdkface.facelight.process.FaceVerifyStatus
import com.tencent.cloud.huiyansdkface.facelight.api.WbCloudFaceContant
import site.xxsy.match.network.TencentFaceIdApi
import site.xxsy.match.network.model.FaceIdRequest
import site.xxsy.match.network.model.FaceIdResponse
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.security.MessageDigest
import kotlinx.coroutines.delay
import kotlin.coroutines.suspendCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.Continuation

class FaceIdHandler(private val context: Context) {
    companion object {
        private const val TAG = "TencentFaceId"
        private const val APP_ID = "TIDAsDk5" // 使用与API调用相同的APP_ID
        private const val LICENSE = "QNNBYGoRtZ8DtvItSo64VP4fdBQPbPPY6CVwO9BWQfPKNZi3JqFFtP5iSEAL7T2IRkbuwCiPU3jiN9LM3Tugx+2uyubB5hHlfiTWNPESrBSWKbRcxQa4Xj55ko8xCT1MvV3fEqoo8zfCDnBOHqxwExUZjwCY7lJxDnbdDx/97bZ8axh25N+98VslyrWYKlt1ePD9ROqM+uQs5qMfIhfYCQd53je/yqpp0LO6NEQnz5rc32MSwcX7RLcqM9ND0oWKTxXhW72fLt457f5JU/zSqzD3KOyNoiMrFZlxKpkx8q7p/v7uGFA3kRAB6JK6AT/cQbnwdAX4wRVKtWODky/NGA==" // 替换为真实LICENSE
        private const val SECRET = "alndsQcJGYNg1N7kv5RGwGmpJQ8RmM0833xLhLUe28w9gVCKcdQwP4q2YpK4Zrgq" // 使用与API调用相同的SECRET
    }

    private val retrofit = Retrofit.Builder()
        .baseUrl("https://kyc1.qcloud.com/")
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    private val faceIdApi = retrofit.create(TencentFaceIdApi::class.java)

    private fun generateNonce(): String {
        val chars = ('A'..'Z') + ('a'..'z') + ('0'..'9')
        val nonce = (1..32).map { chars.random() }.joinToString("")
        Log.d(TAG, "生成nonce: $nonce (长度: ${nonce.length})")
        
        // 验证nonce格式
        if (nonce.length != 32) {
            Log.e(TAG, "警告：生成的nonce长度不是32位: ${nonce.length}")
        }
        if (!nonce.matches(Regex("^[A-Za-z0-9]{32}$"))) {
            Log.e(TAG, "警告：生成的nonce格式不正确，应只包含字母和数字")
        }
        
        return nonce
    }

    // 这个函数应该从你的服务器获取真实签名
    private suspend fun generateSign(appId: String, orderNo: String, nonce: String): String {
        // 实现应该调用你的后端服务获取签名
        // 这里只是示例，实际应用中不要硬编码签名
        return "TEST_SIGN_${System.currentTimeMillis()}"
    }

    // SHA1 签名算法
    private fun sha1(input: String): String {
        val md = MessageDigest.getInstance("SHA-1")
        // 去除所有不可见字符，防止IDE自动加BOM
        val cleanInput = input.replace(Regex("[\\uFEFF-\\uFFFF]"), "")
        val byteArr = cleanInput.toByteArray(Charsets.UTF_8)
        Log.d(TAG, "拼接字符串UTF-8字节: " + byteArr.joinToString(",") { it.toUByte().toString(16).padStart(2, '0') })
        val bytes = md.digest(byteArr)
        return bytes.joinToString("") { "%02x".format(it) }.uppercase()
    }

    // 修正后的签名算法，按照腾讯云官方文档（字典序排序后拼接）
    private fun sign(appId: String, userId: String, version: String, ticket: String, nonce: String): String {
    val params = listOf(appId, userId, version, ticket, nonce).sorted()
    val concatenated = params.joinToString("")
    return sha1(concatenated).uppercase()
}


    // 验证身份证号格式
    private fun validateIdNo(idNo: String): Boolean {
        if (idNo.length != 18) return false
        
        // 检查前17位是否为数字
        val first17 = idNo.substring(0, 17)
        if (!first17.matches(Regex("^[0-9]+$"))) return false
        
        // 检查最后一位是否为数字或X
        val last = idNo.substring(17, 18)
        if (!last.matches(Regex("^[0-9Xx]$"))) return false
        
        // 验证校验码
        return validateIdNoChecksum(idNo)
    }
    
    // 验证身份证号校验码
    private fun validateIdNoChecksum(idNo: String): Boolean {
        val weights = intArrayOf(7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2)
        val checkCodes = charArrayOf('1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2')
        
        var sum = 0
        for (i in 0..16) {
            sum += (idNo[i] - '0') * weights[i]
        }
        
        val checkCode = checkCodes[sum % 11]
        return idNo[17].uppercaseChar() == checkCode
    }

    // 验证姓名格式
    private fun validateName(name: String): Boolean {
        if (name.isBlank() || name.length < 2 || name.length > 20) return false
        
        // 检查是否只包含中文字符、英文字母和空格
        if (!name.matches(Regex("^[\\u4e00-\\u9fa5a-zA-Z\\s]+$"))) return false
        
        return true
    }

    suspend fun initSDK(userId: String, name: String, idNo: String): Boolean {
        return try {
            Log.d(TAG, "=== 开始初始化SDK ===")
            Log.d(TAG, "参数: userId=$userId, name=$name, idNo=$idNo")
            
            // 参数去除首尾空格
            val cleanUserId = userId.trim().replace(Regex("[^A-Za-z0-9_]"), "")
            val cleanName = name.trim()
            val cleanIdNo = idNo.trim()
            
            // 验证参数格式
            Log.d(TAG, "开始验证参数格式...")
            Log.d(TAG, "验证姓名: $cleanName")
            Log.d(TAG, "验证身份证号: $cleanIdNo")
            
            if (!validateName(cleanName)) {
                throw Exception("姓名格式不正确，长度应在2-20个字符之间，且只能包含中文字符、英文字母和空格")
            }
            
            Log.d(TAG, "身份证号原始: [$cleanIdNo], 长度: ${cleanIdNo.length}")
            cleanIdNo.forEachIndexed { idx, c -> Log.d(TAG, "第${idx+1}位: [$c] ASCII: ${c.code}") }
            val first17 = cleanIdNo.substring(0, 17)
            val last = cleanIdNo.substring(17, 18)
            Log.d(TAG, "前17位: [$first17], 最后一位: [$last]")
            Log.d(TAG, "前17位是否全数字: ${first17.matches(Regex("^[0-9]+$"))}")
            Log.d(TAG, "最后一位是否数字或X: ${last.matches(Regex("^[0-9Xx]$"))}")
            Log.d(TAG, "校验码算法通过: ${validateIdNoChecksum(cleanIdNo)}")
            
            if (!validateIdNo(cleanIdNo)) {
                throw Exception("身份证号格式不正确，应为18位数字，且最后一位只能是数字或X")
            }
            
            Log.d(TAG, "参数验证通过")
            
            // 测试签名算法
            testSignAlgorithm()
            
            val orderNo = "order_${System.currentTimeMillis()}"
            val nonce = generateNonce()
            
            Log.d(TAG, "生成的orderNo: $orderNo")
            Log.d(TAG, "生成的nonce: $nonce")

            // 1. 获取 Access Token
            val accessTokenResp = faceIdApi.getAccessToken(
                appId = APP_ID,
                secret = SECRET
            )
            Log.e(TAG, "AccessTokenResp: $accessTokenResp")
            val accessToken = accessTokenResp.body()?.access_token
            if (accessToken.isNullOrEmpty()) {
                throw Exception("获取access_token失败: ${accessTokenResp.body()?.msg}")
            }

            // 2. 获取 SIGN ticket
            val signTicketResp = faceIdApi.getApiTicket(
                appId = APP_ID,
                accessToken = accessToken,
                type = "SIGN"
            )
            Log.e(TAG, "SignTicketResp: $signTicketResp")
            val signTicket = signTicketResp.body()?.tickets?.firstOrNull()?.value
            if (signTicket.isNullOrEmpty()) {
                throw Exception("获取SIGN ticket失败: ${signTicketResp.body()?.msg}")
            }

            // 3. 获取全新的 NONCE ticket（每次都重新获取）
            val nonceTicketResp = faceIdApi.getApiTicket(
                appId = APP_ID,
                accessToken = accessToken,
                type = "NONCE",
                userId = cleanUserId
            )
            Log.e(TAG, "NonceTicketResp: $nonceTicketResp")
            val nonceTicket = nonceTicketResp.body()?.tickets?.firstOrNull()?.value
            if (nonceTicket.isNullOrEmpty()) {
                throw Exception("获取NONCE ticket失败: ${nonceTicketResp.body()?.msg}")
            }

            // 添加延迟，确保 ticket 在服务器端生效
            Log.d(TAG, "获取到 nonce ticket，等待 1 秒确保生效...")
            delay(1000)
            Log.d(TAG, "开始处理 faceId 请求...")

            // 4. 生成签名（用于 getFaceId）
            val getFaceIdSign = sign(APP_ID, cleanUserId, "1.0.0", signTicket, nonce)

            // 打印 getFaceId 参数
            Log.e(TAG, "getFaceId params: appId=$APP_ID, orderNo=$orderNo, userId=$cleanUserId, sign=$getFaceIdSign, nonce=$nonce")

            // 5. 获取 faceId
            val response = faceIdApi.getFaceId(
                request = FaceIdRequest(
                    appId = APP_ID,
                    orderNo = orderNo,
                    userId = cleanUserId,
                    sign = getFaceIdSign,
                    nonce = nonce,
                    name = cleanName,
                    idNo = cleanIdNo
                )
            )

            Log.e(TAG, "getFaceId response.body: ${response.body()}")
            Log.e(TAG, "response.isSuccessful=${response.isSuccessful}, body=${response.body()}, errorBody=${response.errorBody()?.string()}")

            if (!response.isSuccessful) {
                throw Exception("获取faceId失败: ${response.errorBody()?.string()}")
            }
            
            val responseBody = response.body()
            if (responseBody == null) {
                throw Exception("获取faceId失败: 响应体为空")
            }
            
            // 检查业务错误码
            if (responseBody.code != "0") {
                throw Exception("获取faceId失败: ${responseBody.msg} (错误码: ${responseBody.code})")
            }
            
            if (responseBody.result?.faceId == null) {
                throw Exception("获取faceId失败: faceId为空")
            }

            val faceId = responseBody.result!!.faceId!!

            // SDK 初始化时用全新的 NONCE ticket 和 nonce
            val sdkNonceTicketResp = faceIdApi.getApiTicket(
                appId = APP_ID,
                accessToken = accessToken,
                type = "NONCE",
                userId = cleanUserId
            )
            Log.e(TAG, "SDK NonceTicketResp: $sdkNonceTicketResp")
            val sdkNonceTicket = sdkNonceTicketResp.body()?.tickets?.firstOrNull()?.value
            if (sdkNonceTicket.isNullOrEmpty()) {
                throw Exception("获取SDK用NONCE ticket失败: ${sdkNonceTicketResp.body()?.msg}")
            }
            val sdkNonce = generateNonce()
            val sdkOrderNo = "order_${System.currentTimeMillis()}_sdk"
            Log.d(TAG, "SDK初始化使用新的nonce: $sdkNonce")
            Log.d(TAG, "SDK初始化使用新的orderNo: $sdkOrderNo")
            
            // 验证 nonce ticket 是否仍然有效
            Log.d(TAG, "验证 nonce ticket 有效性...")
            Log.d(TAG, "nonce ticket: $sdkNonceTicket")
            if (sdkNonceTicket.isBlank()) {
                throw Exception("nonce ticket 为空，无法进行SDK初始化")
            }
            
            // 验证所有参数
            Log.d(TAG, "=== 参数验证 ===")
            Log.d(TAG, "APP_ID: $APP_ID (长度: ${APP_ID.length})")
            Log.d(TAG, "userId: $cleanUserId (长度: ${cleanUserId.length})")
            Log.d(TAG, "version: 1.0.0")
            Log.d(TAG, "nonceTicket: $sdkNonceTicket (长度: ${sdkNonceTicket?.length})")
            Log.d(TAG, "sdkNonce: $sdkNonce (长度: ${sdkNonce.length})")
            Log.d(TAG, "faceId: $faceId (长度: ${faceId.length})")
            Log.d(TAG, "=================")
            
            val sdkSign = sign(APP_ID, cleanUserId, "1.0.0", sdkNonceTicket, sdkNonce)

            // 添加SDK签名日志
            Log.d(TAG, "=== SDK签名参数 ===")
            Log.d(TAG, "SDK签名参数: appId=$APP_ID, userId=$cleanUserId, version=1.0.0, ticket=$sdkNonceTicket, nonce=$sdkNonce")
            Log.d(TAG, "SDK生成签名: $sdkSign")
            Log.d(TAG, "==================")


            Log.d(TAG, "=== SDK InputData 参数 ===")
            Log.d(TAG, "faceId: $faceId")
            Log.d(TAG, "agreementNo: $sdkOrderNo")
            Log.d(TAG, "openApiAppId: $APP_ID")
            Log.d(TAG, "openApiAppVersion: 1.0.0")
            Log.d(TAG, "openApiNonce: $sdkNonce")
            Log.d(TAG, "openApiUserId: $cleanUserId")
            Log.d(TAG, "openApiSign: $sdkSign")
            Log.d(TAG, "verifyMode: ${FaceVerifyStatus.Mode.GRADE}")
            Log.d(TAG, "keyLicence: ${LICENSE.take(20)}...")
            Log.d(TAG, "=========================")

            // 初始化SDK时确保参数一致

            val inputData = WbCloudFaceVerifySdk.InputData(
    faceId,
    sdkOrderNo,
    APP_ID,
    "1.0.0",
    sdkNonce,
    cleanUserId,
    sdkSign,
    FaceVerifyStatus.Mode.GRADE,
    LICENSE
)

            // 添加SDK初始化参数日志
            Log.d(TAG, "=== SDK初始化参数 ===")
            Log.d(TAG, "faceId: $faceId")
            Log.d(TAG, "orderNo: $sdkOrderNo")  // 更新日志显示新的 orderNo
            Log.d(TAG, "appId: $APP_ID")
            Log.d(TAG, "version: 1.0.0")
            Log.d(TAG, "nonceTicket: $sdkNonceTicket")
            Log.d(TAG, "userId: $cleanUserId")
            Log.d(TAG, "sdkSign: $sdkSign")
            Log.d(TAG, "license: ${LICENSE.take(20)}...")
            Log.d(TAG, "=====================")

            val bundle = Bundle().apply {
                putSerializable(WbCloudFaceContant.INPUT_DATA, inputData)
                // 个性化参数设置
                putString(WbCloudFaceContant.LANGUAGE, WbCloudFaceContant.LANGUAGE_EN) // 语言：英文
                putString(WbCloudFaceContant.COLOR_MODE, WbCloudFaceContant.WHITE) // SDK样式：白色
                putString(WbCloudFaceContant.CUSTOMER_TIPS_LIVE, "扫描人脸后与您身份证进行对比") // 采集时提示
                putString(WbCloudFaceContant.CUSTOMER_TIPS_UPLOAD, "已提交审核，请等待结果") // 上传时提示
                putInt(WbCloudFaceContant.CUSTOMER_TIPS_LOC, WbCloudFaceContant.CUSTOMER_TIPS_LOC_TOP) // 提示语位置：上方
                putString(WbCloudFaceContant.COMPARE_TYPE, WbCloudFaceContant.ID_CARD) // 比对类型：权威数据源对比
                putBoolean(WbCloudFaceContant.VIDEO_UPLOAD, false) // 不录制视频
                putBoolean(WbCloudFaceContant.VIDEO_CHECK, false) // 不检测视频
                putBoolean(WbCloudFaceContant.PLAY_VOICE, false) // 不播放语音提示
            }

            Log.d(TAG, "开始调用 SDK initSdk...")
            
            // 使用 suspendCoroutine 来处理异步回调
            return suspendCoroutine<Boolean> { continuation ->
                WbCloudFaceVerifySdk.getInstance().initSdk(context, bundle,
                    object : WbCloudFaceVerifyLoginListener {
                        override fun onLoginSuccess() { 
                            Log.d(TAG, "SDK登录成功")
                            continuation.resume(true)
                        }
                        override fun onLoginFailed(error: WbFaceError?) {
                            Log.e(TAG, "SDK登录失败: ${error?.desc}")
                            Log.e(TAG, "错误代码: ${error?.code}")
                            Log.e(TAG, "错误详情: $error")
                            Log.e(TAG, "错误域: ${error?.domain}")
                            Log.e(TAG, "错误原因: ${error?.reason}")
                            continuation.resumeWithException(Exception("SDK登录失败: ${error?.desc}"))
                        }
                    })
            }
        } catch (e: Exception) {
            Log.e(TAG, "初始化失败", e)
            false
        }
    }

    

    fun startVerification(callback: (Map<String, Any?>) -> Unit) {
        WbCloudFaceVerifySdk.getInstance().startWbFaceVerifySdk(
            context,
            object : WbCloudFaceVerifyResultListener {
                override fun onFinish(result: WbFaceVerifyResult?) {
                    val resultMap = mutableMapOf<String, Any?>(
                        "isSuccess" to result?.isSuccess,
                        "liveRate" to result?.liveRate,
                        "similarity" to result?.similarity
                    )
                    result?.error?.let { err ->
                        resultMap["error"] = mapOf(
                            "code" to err.code,
                            "message" to err.desc
                        )
                    }
                    callback(resultMap)
                    WbCloudFaceVerifySdk.getInstance().release()
                }
            }
        )
    }

    // 测试签名算法，使用官方文档示例
    fun testSignAlgorithm() {
        val testAppId = "TIDAsDk5"
        val testUserId = "userID19959248596551"
        val testVersion = "1.0.0"
        val testTicket = "XO99Qfxlti9iTVgHAjwvJdAZKN3nMuUhrsPdPlPVKlcyS50N6tlLnfuFBPIucaMS"
        val testNonce = "kHoSxvLZGxSoFsjxlbzEoUzh5PAnTU7T"

        val expectedConcatenated = "TIDAsDk5userID199592485965511.0.0XO99Qfxlti9iTVgHAjwvJdAZKN3nMuUhrsPdPlPVKlcyS50N6tlLnfuFBPIucaMSkHoSxvLZGxSoFsjxlbzEoUzh5PAnTU7T"
        val expectedSignature = "D7606F1741DDCF90757DA924EDCF152A200AC7F0"

        Log.d(TAG, "参数长度: appId=${testAppId.length}, userId=${testUserId.length}, version=${testVersion.length}, ticket=${testTicket.length}, nonce=${testNonce.length}")
        Log.d(TAG, "参数内容: appId=[$testAppId], userId=[$testUserId], version=[$testVersion], ticket=[$testTicket], nonce=[$testNonce]")

        val actualConcatenated = testAppId + testUserId + testVersion + testTicket + testNonce
        Log.d(TAG, "拼接字符串: [$actualConcatenated]")
        Log.d(TAG, "期望拼接字符串: [$expectedConcatenated]")
        Log.d(TAG, "拼接是否一致: ${actualConcatenated == expectedConcatenated}")

        val actualSignature = sha1(actualConcatenated)
        Log.d(TAG, "实际签名: $actualSignature")
        Log.d(TAG, "期望签名: $expectedSignature")
        Log.d(TAG, "签名是否一致: ${actualSignature == expectedSignature}")
    }
}