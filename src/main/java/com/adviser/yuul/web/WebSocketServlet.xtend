package com.adviser.yuul.web

import org.eclipse.jetty.websocket.servlet.WebSocketServlet
import org.eclipse.jetty.websocket.servlet.WebSocketServletFactory

class YuulWebServlet extends WebSocketServlet {
 
    override configure(WebSocketServletFactory factory) {
        factory.getPolicy().setIdleTimeout(10000);
        factory.register(YuulWebSocket);
    }
}
