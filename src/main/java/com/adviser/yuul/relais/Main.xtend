package com.adviser.yuul.relais

import org.eclipse.jetty.websocket.client.WebSocketClient
import org.eclipse.jetty.websocket.client.ClientUpgradeRequest
import java.net.URI
import java.util.concurrent.TimeUnit
import com.adviser.yuul.YuulWebSocket
import org.slf4j.LoggerFactory
import com.adviser.yuul.beans.respond.RespondDoorOtp
import com.adviser.yuul.Action
import com.adviser.yuul.beans.request.RequestDoorOtp

class Main {
	
	static val LOGGER = LoggerFactory.getLogger(Main)

	static class ActionRespondDoorOtp implements Action<RespondDoorOtp> {
		static val LOGGER = LoggerFactory.getLogger(ActionRespondDoorOtp)

		override key() {
			RespondDoorOtp.name
		}
		override run(YuulWebSocket yws, RespondDoorOtp t) {
			LOGGER.debug("Got DoorOtp Respond:"+t.doorId+":"+t.doorOtp)
		}

		override onConnect(YuulWebSocket yws) {
			yws.send(new RequestDoorOtp("Door-4711"))
		}
	}

	public static def void main(String[] args) {
		val yuulHubUrl = "ws://localhost:8080/";
		val client = new WebSocketClient();

		val socket = new YuulWebSocket();
		socket.addHandler(new ActionRespondDoorOtp())
		try {
			client.start();
			val yuulHub = new URI(yuulHubUrl);
			val request = new ClientUpgradeRequest();
			client.connect(socket, yuulHub, request);
			LOGGER.debug("Connecting to : %s%n", yuulHub);
			socket.awaitClose(10, TimeUnit.SECONDS);
		} catch(Throwable t) {
			t.printStackTrace();
		} finally {
			try {
				client.stop();
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
	}
}
