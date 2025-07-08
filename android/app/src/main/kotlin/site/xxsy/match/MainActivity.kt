package site.xxsy.match

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class MainActivity: FlutterActivity() {
    private val CHANNEL = "tencent_faceid"
    private lateinit var faceIdHandler: FaceIdHandler
    private val mainScope = MainScope()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        faceIdHandler = FaceIdHandler(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initSDK" -> {
                    try {
                        val userId = call.argument<String>("userId") ?: run {
                            result.error("INVALID_ARGS", "userId不能为空", null)
                            return@setMethodCallHandler
                        }
                        val name = call.argument<String>("name") ?: run {
                            result.error("INVALID_ARGS", "name不能为空", null)
                            return@setMethodCallHandler
                        }
                        val idNo = call.argument<String>("idNo") ?: run {
                            result.error("INVALID_ARGS", "idNo不能为空", null)
                            return@setMethodCallHandler
                        }
                        android.util.Log.e("TencentFaceId", "MainActivity收到参数: userId=$userId, name=$name, idNo=$idNo")
                        mainScope.launch {
                            try {
                                val success = faceIdHandler.initSDK(userId, name, idNo)
                                if (success) result.success(true)
                                else result.error("INIT_FAILED", "SDK初始化失败", null)
                            } catch (e: Exception) {
                                result.error("INIT_ERROR", e.message, null)
                            }
                        }
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", e.message, null)
                    }
                }
                "startVerification" -> {
                    faceIdHandler.startVerification { res ->
                        result.success(res)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}