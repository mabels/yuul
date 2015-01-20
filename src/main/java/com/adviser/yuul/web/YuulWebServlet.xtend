package com.adviser.yuul.web

import org.eclipse.jetty.websocket.servlet.WebSocketServlet
import org.eclipse.jetty.websocket.servlet.WebSocketServletFactory
import com.adviser.yuul.YuulWebSocket
import org.eclipse.jetty.websocket.servlet.WebSocketCreator
import org.eclipse.jetty.websocket.servlet.ServletUpgradeRequest
import org.eclipse.jetty.websocket.servlet.ServletUpgradeResponse

class YuulWebServlet extends WebSocketServlet {
	
	val yws = new YuulWebSocket()

	static class YuulWebSocketCreator implements WebSocketCreator {
		
		val YuulWebSocket yws
		
		new(YuulWebSocket yws) {
			this.yws = yws
		}
		override createWebSocket(ServletUpgradeRequest req, ServletUpgradeResponse resp) {
			this.yws
		}
		
	}
	override configure(WebSocketServletFactory factory) {
		factory.getPolicy().setIdleTimeout(10000);
		factory.creator = new YuulWebSocketCreator(yws)
	}
	
	def getYws() {
		yws
	}
}
