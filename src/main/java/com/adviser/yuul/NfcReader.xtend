package com.adviser.yuul

import javax.smartcardio.TerminalFactory
import javax.smartcardio.CardTerminal
import javax.smartcardio.CardChannel
import javax.smartcardio.Card
import java.util.List
import java.util.LinkedList
import java.util.Map
import java.util.HashMap

import org.slf4j.Logger
import org.slf4j.LoggerFactory

class NfcReaderFactory {
	
	val TerminalFactory factory = TerminalFactory.getDefault();
	val Map<String, NfcReaderService> terminals = new HashMap<String, NfcReaderService>()

	def getService() {
		return getService(null)
	}

	def getService(String readername) {
		var NfcReaderService nrs = terminals.get(readername);
		if(nrs != null) {
			return nrs;
		}
		var CardTerminal ct = null
		val list = factory.terminals().list()
		if(readername == null && list.size() > 0) {
			ct = list.get(0);
		} else {
			ct = factory.terminals().list().findFirst[i|readername.equals(i.name)]
		}
		if(ct == null) {
			return null;
		}
		nrs = new NfcReaderService(ct);
		terminals.put(nrs.getName, nrs);
		nrs
	}

	static class NfcReaderService {
		static val LOGGER = LoggerFactory.getLogger(NfcReaderService);
		val CardTerminal terminal
		var Thread thread;
		var boolean stopped = false

		static abstract class NfcCallback {
			def void call(Card card, CardChannel cc)
		}

		val List<NfcCallback> callbacks = new LinkedList<NfcCallback>()

		def addCallback(NfcCallback nc) {
			callbacks.add(nc)
		}

		new(CardTerminal _terminal) {
			terminal = _terminal
		}

		def getName() {
			terminal.getName
		}

		def stop() {
			stopped = true
		}

		def Thread start() {
			if(thread != null) {
				return null
			}
			thread = new Thread(
				new Runnable {
					override run() {
						while(!stopped) {
							if(terminal.waitForCardPresent(500)) {
								try {
									val Card card = terminal.connect("*")
									val CardChannel channel = card.getBasicChannel()
									callbacks.forEach[cb|cb.call(card, channel)]
								} catch(Exception e) {
									LOGGER.error("Card:", e)
								}
								while(!stopped && !terminal.waitForCardAbsent(500)) {
								}
							}
						}
					}
				})
			thread.start
			return thread
		}

	}

}
