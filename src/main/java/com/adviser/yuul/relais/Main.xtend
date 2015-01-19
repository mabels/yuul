package com.adviser.yuul.relais

import org.eclipse.jetty.websocket.client.WebSocketClient
import org.eclipse.jetty.websocket.client.ClientUpgradeRequest
import java.net.URI
import java.util.concurrent.TimeUnit

class Main {

	public static def void main(String[] args) {
		var destUri = "ws://localhost:8080/";
		if(args.length > 0) {
			destUri = args.get(0);
		}
		val client = new WebSocketClient();
		val socket = new RelaisConnector();
		try {
			client.start();
			val echoUri = new URI(destUri);
			val request = new ClientUpgradeRequest();
			client.connect(socket, echoUri, request);
			System.out.printf("Connecting to : %s%n", echoUri);
			socket.awaitClose(5, TimeUnit.SECONDS);
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

