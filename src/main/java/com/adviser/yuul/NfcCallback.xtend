package com.adviser.yuul

import javax.smartcardio.CardChannel
import javax.smartcardio.Card

interface NfcCallback {
	def void call(Card card, CardChannel cc, OtpTransaction transaction)
}
