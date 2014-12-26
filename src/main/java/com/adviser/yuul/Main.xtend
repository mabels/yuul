package com.adviser.yuul

import com.adviser.yuul.NfcReaderFactory.NfcReaderService
import com.adviser.yuul.NfcReaderFactory.NfcReaderService.NfcCallback

import org.slf4j.Logger
import org.slf4j.LoggerFactory

class Main {
	static val LOGGER = LoggerFactory.getLogger(Main);

	def static void main(String[] args) {
		LOGGER.info("Starting Yuul")
		val nrf = new NfcReaderFactory
		var NfcReaderService nrs
		if(args.length > 0) {
			nrs = nrf.getService(args.last)
		} else {
			nrs = nrf.getService()
		}
		if (nrs == null) {
			LOGGER.error("no reader found")
			return
		}
		nrs.addCallback(new YubiKey(ClientID, Secretkey))
		nrs.start()
		while(true) {
			Thread.sleep(3600000);
		}
	}
}
