package com.adviser.yuul.web

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.StatusCode;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketClose;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketConnect;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketMessage;
import org.eclipse.jetty.websocket.api.annotations.WebSocket;
import com.google.gson.Gson
import com.adviser.yuul.beans.RequestDoorList
import com.adviser.yuul.beans.RespondDoorList
import org.slf4j.LoggerFactory
import java.util.List
import java.util.ArrayList
import java.util.LinkedList

/**
 * Basic Echo Client Socket
 */
@WebSocket(maxTextMessageSize=64 * 1024)
class YuulWebSocket {

	static val LOGGER = LoggerFactory.getLogger(YuulWebSocket)

	val gson = new Gson()

	val closeLatch = new CountDownLatch(1)

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

    interface Action<T> {
		def void run(T t)
	}
	static class Handler<T> {
		public val Class clazz
		val actions = new LinkedList<Action<T>>()
		new(Class clazz) {
			this.clazz = clazz
		}
		def add_action(Action<T> a) {
			actions.push(a)
		}
		def invoke(Object t) {
			actions.forEach[action| action.run(t as T)]
		}
	}
	val factory = #{
		"RequestDoorList" -> new Handler<RequestDoorList>(RequestDoorList),
		"RespondDoorList" -> new Handler<RespondDoorList>(RespondDoorList)
	}

	@OnWebSocketMessage
	def void onMessage(String msg) {
		System.out.printf("Got msg: %s%n", msg)
		val ret = msg.indexOf(':')
		if(ret <= 0) {
			LOGGER.error("msg format invalid:" + msg)
			return
		}
		val msg_type = msg.substring(0, ret - 1)

		val handler = factory.get(msg_type)
		if(handler == null) {
			LOGGER.error("msg type not found:" + msg_type)
			return
		}
		val obj = gson.fromJson(msg.substring(ret + 1), handler.clazz)
		handler.invoke(obj)
	}
}
