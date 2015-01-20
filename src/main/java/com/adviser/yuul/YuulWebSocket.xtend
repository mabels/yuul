package com.adviser.yuul

import com.adviser.yuul.beans.request.RequestDoorList
import com.adviser.yuul.beans.request.RequestDoorOtp
import com.adviser.yuul.beans.request.RequestOpenDoor
import com.adviser.yuul.beans.request.RequestRegisterApp
import com.adviser.yuul.beans.request.RequestRegisterDoor
import com.adviser.yuul.beans.respond.RespondDoorList
import com.adviser.yuul.beans.respond.RespondOpenDoor
import com.adviser.yuul.beans.respond.RespondRegisterApp
import com.adviser.yuul.beans.respond.RespondRegisterDoor
import com.google.gson.Gson
import java.io.StringWriter
import java.util.HashMap
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import org.eclipse.jetty.websocket.api.Session
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketClose
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketConnect
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketMessage
import org.eclipse.jetty.websocket.api.annotations.WebSocket
import org.slf4j.LoggerFactory
import com.adviser.yuul.beans.respond.RespondDoorOtp

/**
 * Basic Echo Client Socket
 */
@WebSocket(maxTextMessageSize=64 * 1024)
class YuulWebSocket {

	static val LOGGER = LoggerFactory.getLogger(YuulWebSocket)

	val gson = new Gson()

	val closeLatch = new CountDownLatch(1)

	def static addFactory(HashMap<String, WebSocketHandler> map, int hashcode, WebSocketHandler wsh) {
		LOGGER.debug("addFactory:" + hashcode + ":" + wsh.key)
		map.put(wsh.key, wsh)
	}

	def static createFactory(int hashcode) {
		val ret = new HashMap<String, WebSocketHandler>()
		addFactory(ret, hashcode, new GenericHandler<RespondRegisterDoor>(RespondRegisterDoor))
		addFactory(ret, hashcode, new GenericHandler<RespondRegisterApp>(RespondRegisterApp))
		addFactory(ret, hashcode, new GenericHandler<RespondOpenDoor>(RespondOpenDoor))
		addFactory(ret, hashcode, new GenericHandler<RespondDoorList>(RespondDoorList))
		addFactory(ret, hashcode, new GenericHandler<RespondDoorOtp>(RespondDoorOtp))
		addFactory(ret, hashcode, new GenericHandler<RequestRegisterDoor>(RequestRegisterDoor))
		addFactory(ret, hashcode, new GenericHandler<RequestRegisterApp>(RequestRegisterApp))
		addFactory(ret, hashcode, new GenericHandler<RequestOpenDoor>(RequestOpenDoor))
		addFactory(ret, hashcode, new GenericHandler<RequestDoorOtp>(RequestDoorOtp))
		addFactory(ret, hashcode, new GenericHandler<RequestDoorList>(RequestDoorList))
		ret
	}

	val factory = createFactory(this.hashCode)

	def addHandler(Action t) {
		LOGGER.debug("addHandler:" + t.key)
		factory.get(t.key).add_action(t)
	}

	@SuppressWarnings("unused")
	private Session session;

	def awaitClose(int duration, TimeUnit unit) throws InterruptedException {
		return this.closeLatch.await(duration, unit);
	}

	@OnWebSocketClose
	def void onClose(int statusCode, String reason) {
		System.out.printf("Connection closed: %d - %s%n", statusCode, reason);
		this.session = null;
		this.closeLatch.countDown();
	}

	@OnWebSocketConnect
	def void onConnect(Session session) {
		System.out.printf("Got connect: %s%n", session);
		this.session = session;
		factory.forEach[k, handler|handler.onConnect(this)]

	//        try {
	//            var Future<Void> fut;
	//            fut = session.getRemote().sendStringByFuture("Hello");
	//            fut.get(2, TimeUnit.SECONDS);
	//            fut = session.getRemote().sendStringByFuture("Thanks for the conversation.");
	//            fut.get(2, TimeUnit.SECONDS);
	//            session.close(StatusCode.NORMAL, "I'm done");
	//        } catch (Throwable t) {
	//            t.printStackTrace();
	//        }
	}

	def void send(Object obj) {
		val out = new StringWriter()
		out.append(obj.class.name)
		out.append(':')
		gson.toJson(obj, out)
		LOGGER.debug("send:" + out.toString())
		session.remote.sendString(out.toString())
	}

	@OnWebSocketMessage
	def void onMessage(String msg) {
		LOGGER.debug("Got msg:" + msg)
		val ret = msg.indexOf(':')
		if(ret <= 0) {
			LOGGER.error("msg format invalid:" + msg)
			return
		}
		val msg_type = msg.substring(0, ret)
		val handler = factory.get(msg_type)
		LOGGER.debug("Found msg_type:" + msg_type+":"+handler)
		if(handler == null) {
			LOGGER.error("msg type not found:" + msg_type)
			return
		}
		val obj = gson.fromJson(msg.substring(ret + 1), handler.clazz)
		LOGGER.debug("got obj from json:"+obj)
		handler.invoke(this, obj)
	}
}
