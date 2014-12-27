package com.adviser.yuul

import java.io.ByteArrayOutputStream
import java.util.Queue
import javax.smartcardio.Card
import javax.smartcardio.CardChannel
import javax.smartcardio.CommandAPDU
import javax.smartcardio.ResponseAPDU
import org.slf4j.LoggerFactory
import com.adviser.yuul.NfcReaderFactory.NfcReaderService.NfcCallback

class ReadYubiKeyOtp extends NfcCallback {
	static val LOGGER = LoggerFactory.getLogger(ReadYubiKeyOtp)

	val Queue<String> otpQueue

	new(Queue _otpQueue) {
		otpQueue = _otpQueue
	}

	static class SimpleExcept {
		val int[] send

		new(int[] _send) {
			send = _send
		}

		def int[] send() {
			return send
		}

		def boolean respond(ResponseAPDU a) {
			return a.SW1 == 0x90 && a.SW2 == 0x00
		}
	}

	static class ProcessUri extends SimpleExcept {
		val ReadYubiKeyOtp ref

		new(int[] _send, ReadYubiKeyOtp _ref) {
			super(_send)
			ref = _ref
		}

		def getOtp(ResponseAPDU answer) {
			val byte[] r = answer.getData()
			val boas = new ByteArrayOutputStream()
			(7 .. r.length - 1).forEach[i|boas.write(r.get(i))]
			return boas.toString.split("/").last
		}

		override def boolean respond(ResponseAPDU a) {
			val ret = super.respond(a)
			if(!ret) {
				return false
			}
			ref.otpQueue.add(getOtp(a))
			return true
		}
	}

	val cmds = #[
		new SimpleExcept(#[0x00, 0xa4, 0x04, 0x00, 0x07, 0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01, 0x00]),
		new SimpleExcept(#[0x00, 0xA4, 0x00, 0x0c, 0x02, 0xE1, 0x04]),
		new ProcessUri(#[0x00, 0xb0, 0x00, 0x00, 0x00], this)
	]



	def ResponseAPDU transmit(CardChannel cc, SimpleExcept se) {
		LOGGER.debug("Send>>" + Yuul.asString(se.send))
		val data = Yuul.asBytes(se.send)
		val answer = cc.transmit(new CommandAPDU(data))
		LOGGER.debug("Recv<<" + Yuul.asString(answer.bytes))
		answer
	}

	override call(Card card, CardChannel cc) {
		cmds.forEach [ cmd |
			val ret = transmit(cc, cmd)
			if(!cmd.respond(ret)) {
				LOGGER.error("can not process APDU=" + Yuul.asString(cmd.send))
				return
			}
		]
	}
}
