package com.adviser.yuul

import java.util.LinkedList
import org.slf4j.LoggerFactory

class GenericHandler<T> implements WebSocketHandler<T> {

	static val LOGGER = LoggerFactory.getLogger(GenericHandler)
	public val Class<T> clazz
	val actions = new LinkedList<Action<T>>()

	new(Class<T> clazz) {
		this.clazz = clazz
	}

	override key() {
		this.clazz.name
	}

	override Class<T> clazz() {
		clazz
	}

	override add_action(Action<T> a) {
		actions.push(a)
	}

	override invoke(YuulWebSocket yws, Object t) {
		LOGGER.debug("invoke for obj:"+t.class.name+":"+actions)
		actions.forEach[action|action.run(yws, t as T)]
	}

	override onConnect(YuulWebSocket yws) {
		actions.forEach[action|action.onConnect(yws)]
	}
}
