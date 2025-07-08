package site.xxsy.match

import io.dcloud.common.adapter.util.Logger
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.dcloud.feature.sdk.DCUniMPSDK
import io.dcloud.feature.sdk.DCSDKInitConfig
import io.dcloud.feature.sdk.MenuActionSheetItem
import android.util.Log

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "site.xxsy.match/uniapp"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openUniApp" -> {
                    try {
                        val appId = call.argument<String>("appId")
                        if (appId != null) {
                            // 设置右上角胶囊操作菜单
                            val item = MenuActionSheetItem("关于", "about")
                            val sheetItems: MutableList<MenuActionSheetItem> = ArrayList()
                            sheetItems.add(item)
                            
                            // 初始化uniMPSDK
                            val config = DCSDKInitConfig.Builder()
                                .setCapsule(true)
                                .setMenuDefFontSize("16px")
                                .setMenuDefFontColor("#2D2D2D")
                                .setMenuDefFontWeight("normal")
                                .setMenuActionSheetItems(sheetItems)
                                .build()
                            DCUniMPSDK.getInstance().initialize(this, config)

                            // 打开小程序
                            DCUniMPSDK.getInstance().openUniMP(this, appId)
                            
                            // 监听胶囊菜单点击事件
                            DCUniMPSDK.getInstance().setDefMenuButtonClickCallBack { argumentAppID, id ->
                                when (id) {
                                    "about" -> {
                                        Logger.e("$argumentAppID 点击了关于")
                                    }
                                }
                            }
                            
                            // 监听小程序关闭
                            DCUniMPSDK.getInstance()
                                .setUniMPOnCloseCallBack { argumentAppID -> 
                                    Log.e("unimp", "$argumentAppID 被关闭了") 
                                }
                                
                            result.success(null)
                        } else {
                            result.error("INVALID_ARGUMENT", "AppId cannot be null", null)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
