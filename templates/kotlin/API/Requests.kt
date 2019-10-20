package com.example.androidtest1.API

import kotlinx.serialization.Serializable

@Serializable
data class RequestSample(var name: String) {//: APIRequest {
//    override val method = Method.post
//    override val urlPath = "ololo"
}
