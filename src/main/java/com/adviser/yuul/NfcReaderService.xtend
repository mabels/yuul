package com.adviser.yuul

import org.slf4j.LoggerFactory
import java.util.List
import java.util.LinkedList
import javax.smartcardio.CardChannel
import javax.smartcardio.Card

class NfcReaderService {
	static val LOGGER = LoggerFactory.getLogger(NfcReaderService)
	var Thread thread
	var boolean stopped = false

	val List<NfcCallback> callbacks = new LinkedList<NfcCallback>()
	val String readerName

	new(String _readerName) {
		readerName = _readerName
	}

	def addCallback(NfcCallback nc) {
		callbacks.add(nc)
	}

	def stop() {
		stopped = true
	}

	def processCallbacks(Card card, CardChannel channel, OtpTransaction transaction) {
		callbacks.forEach [ cb |
			transaction.add(cb.class.name)
			cb.call(card, channel, transaction)
		]
	}

	def Thread start() {
		if(thread != null) {
			LOGGER.error("double service start!")
			return null
		}
		val nrs = this
		thread = new Thread(
			new Runnable {
				override run() {
					LOGGER.info("Service Thread running:"+readerName)
					val StateContext context = new StateContext(readerName)
					val State openCardTerminal = new StateOpenCardTerminal(context)
					var State state = openCardTerminal
					while(!stopped) {
						try {
							state = state.execute(nrs)
						} catch(Exception e) {
							LOGGER.error("Reset to initial state caused by:", e)
							Thread.sleep(250)
							state = openCardTerminal
						}
					}
					LOGGER.info("Service Thread stopped")
				}
			})
		thread.start
		LOGGER.info("started")
		return thread
	}

}
