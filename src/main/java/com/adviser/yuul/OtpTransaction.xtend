package com.adviser.yuul

import java.util.LinkedList
import org.slf4j.LoggerFactory

class OtpTransaction {

	static val LOGGER = LoggerFactory.getLogger(StateOpenCardTerminal)

	val points = new LinkedList<Entry>
	var String otp = null

	def add(String title) {
		LOGGER.debug(title)
		points.add(new Entry(title))
	}

	def setOtp(String _otp) {
		otp = _otp
	}

	def getOtp() {
		otp
	}

}
