package com.adviser.yuul

interface Action<T> {
	def String key()
	def void run(YuulWebSocket yws, T t)
	def void onConnect(YuulWebSocket yws)
}
