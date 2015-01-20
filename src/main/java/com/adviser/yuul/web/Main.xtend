package com.adviser.yuul.web

import com.adviser.yuul.Action
import com.adviser.yuul.YuulWebSocket
import com.adviser.yuul.beans.request.RequestDoorList
import org.eclipse.jetty.server.Server
import org.eclipse.jetty.servlet.ServletContextHandler
import org.slf4j.LoggerFactory
import com.adviser.yuul.beans.request.RequestDoorOtp
import com.adviser.yuul.beans.respond.RespondDoorOtp
import org.eclipse.jetty.servlet.ServletHolder

class Main {

	static val LOGGER = LoggerFactory.getLogger(Main)

	static class ActionRequestDoorOtp implements Action<RequestDoorOtp> {
		static val LOGGER = LoggerFactory.getLogger(ActionRequestDoorOtp)

		override key() {
			RequestDoorOtp.name
		}

		override run(YuulWebSocket yws, RequestDoorOtp t) {
			LOGGER.info("Got RequestDoorOtp")
			yws.send(new RespondDoorOtp(t.doorId, "Test"))

		}

		override onConnect(YuulWebSocket yws) {
		}
	}

	public static def void main(String[] args) throws Exception {
		LOGGER.debug("Start-Web-Main")
		val yuulHubServlet = new YuulWebServlet()
		yuulHubServlet.yws.addHandler(new ActionRequestDoorOtp())
		LOGGER.debug("Start Jetty")
		val server = new Server(8080)
		val servletContextHandler = new ServletContextHandler(server, "/", true, false)
		servletContextHandler.
		servletContextHandler.addServlet(new ServletHolder(yuulHubServlet), "/")
		server.start()
		server.join()
	}
}
