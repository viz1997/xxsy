package site.xxsy.match.network.model

data class FaceIdRequest(
    val appId: String,
    val orderNo: String,
    val name: String? = null,
    val idNo: String? = null,
    val userId: String,
    val sourcePhotoStr: String? = null,
    val version: String = "1.0.0",
    val sign: String,
    val nonce: String
)