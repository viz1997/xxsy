package site.xxsy.match.network

import site.xxsy.match.network.model.FaceIdRequest
import site.xxsy.match.network.model.FaceIdResponse
import site.xxsy.match.network.model.AccessTokenResponse
import site.xxsy.match.network.model.ApiTicketResponse
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.POST
import retrofit2.http.GET
import retrofit2.http.Query

interface TencentFaceIdApi {
    @POST("api/server/getfaceid")
    suspend fun getFaceId(
        @Body request: FaceIdRequest
    ): Response<FaceIdResponse>

    // 获取 Access Token
    @GET("api/oauth2/access_token")
    suspend fun getAccessToken(
        @Query("appId") appId: String,
        @Query("secret") secret: String,
        @Query("grant_type") grantType: String = "client_credential",
        @Query("version") version: String = "1.0.0"
    ): Response<AccessTokenResponse>

    // 获取 ticket
    @GET("api/oauth2/api_ticket")
    suspend fun getApiTicket(
        @Query("appId") appId: String,
        @Query("access_token") accessToken: String,
        @Query("type") type: String, // "SIGN" 或 "NONCE"
        @Query("version") version: String = "1.0.0",
        @Query("user_id") userId: String? = null // NONCE 时必填
    ): Response<ApiTicketResponse>
}