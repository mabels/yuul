package com.adviser.yuul

class StateProcessOtp implements State {

	val StateContext stateContext

	new(StateContext _stateContext) {
		stateContext = _stateContext
	}

	override execute(NfcReaderService nrs) {
		val transaction = new OtpTransaction
		transaction.add("CardPresent")
		stateContext.setCard(stateContext.cardTerminal.connect("*"))
		transaction.add("Card: " + stateContext.card + 
						" Card:ATR:" + Yuul.asString(stateContext.card.ATR.bytes) +
						"CardChannel: " + stateContext.card.basicChannel)

		nrs.processCallbacks(stateContext.card, stateContext.card.basicChannel, transaction)

		transaction.add("disconnect")
		//card.disconnect(false)

		return new StateWaitForCardAbsence(stateContext)
	}

}
