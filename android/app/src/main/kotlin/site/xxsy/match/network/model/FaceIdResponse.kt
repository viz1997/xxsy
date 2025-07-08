package site.xxsy.match.network.model

data class FaceIdResponse(
    val code: String?,
    val msg: String?,
    val bizSeqNo: String?,
    val result: FaceIdResultDetail?,
    val transactionTime: String?
)

data class FaceIdResultDetail(
    val bizSeqNo: String?,
    val transactionTime: String?,
    val orderNo: String?,
    val faceId: String?,
    val success: Boolean?
) 