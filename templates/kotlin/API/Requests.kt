package com.example.androidtest1.API

import kotlinx.serialization.Serializable

@Serializable
data class RequestSample(var sss: String): APIRequest {
    override val method: Method = Method.post
    override val path : String= "ololo"
    override val response_type: String = "SomeType"
    override val error_type: String = "SomeErrorType"
}