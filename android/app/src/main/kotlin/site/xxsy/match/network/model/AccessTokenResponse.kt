package site.xxsy.match.network.model

data class AccessTokenResponse(
    val code: String,
    val msg: String,
    val access_token: String?,
    val expire_time: String?,
    val expire_in: Int?
) 