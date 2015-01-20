package com.adviser.yuul

interface WebSocketHandler<T> {
	public def String key()
	public def void add_action(Action<T> a) 
	public def Class<T> clazz()
	public def void invoke(YuulWebSocket yws, Object t)
	public def void onConnect(YuulWebSocket yws)
}

