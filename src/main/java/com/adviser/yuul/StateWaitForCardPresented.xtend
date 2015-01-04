package com.adviser.yuul

import org.slf4j.LoggerFactory

class StateWaitForCardPresented implements State {

	static val LOGGER = LoggerFactory.getLogger(StateWaitForCardPresented)

	val StateContext stateContext

	new(StateContext _stateContext) {
		stateContext = _stateContext
	}

	override execute(NfcReaderService nrs) {
		if(stateContext.resetPresent()) {
			LOGGER.debug("waitForCardPresent:" + stateContext.terminalFactory.terminals.list.size)
		}

		if(stateContext.getCardTerminal.waitForCardPresent(500)) {
			return new StateProcessOtp(stateContext)
		}
		return this
	}

}
