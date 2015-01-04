package com.adviser.yuul

import org.slf4j.LoggerFactory

class StateOpenCardTerminal implements State {

	static val LOGGER = LoggerFactory.getLogger(StateOpenCardTerminal)

	val StateContext stateContext

	new(StateContext _stateContext) {
		stateContext = _stateContext
	}

	override State execute(NfcReaderService unused) {
		LOGGER.info("Found card:" + stateContext.cardTerminal.name)
		new StateWaitForCardPresented(stateContext)
	}

}
