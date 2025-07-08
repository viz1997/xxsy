package site.xxsy.match.network.model

data class ApiTicketResponse(
    val code: String,
    val msg: String,
    val tickets: List<Ticket>?
)

data class Ticket(
    val value: String,
    val expire_in: String?,
    val expire_time: String?
) 