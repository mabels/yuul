package com.adviser.yuul

import org.slf4j.LoggerFactory

class StateWaitForCardAbsence implements State {

	static val LOGGER = LoggerFactory.getLogger(StateWaitForCardAbsence)
	
	val StateContext stateContext
	
	new(StateContext _stateContext) {
		stateContext = _stateContext
	}
	
	override execute(NfcReaderService nrs) {
		if (stateContext.resetAbsent()) {
			LOGGER.debug("waitForCardAbsent")
		}
		if (!stateContext.cardTerminal.waitForCardAbsent(500)) {
			return this
		}
		stateContext.card.disconnect(false)
		return new StateWaitForCardPresented(stateContext)
	}


}
