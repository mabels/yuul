package com.adviser.yuul

import org.slf4j.LoggerFactory 

import org.yaml.snakeyaml.Yaml
import java.util.Map
import java.io.FileInputStream
import java.io.File
import java.io.ByteArrayOutputStream
import java.io.PrintStream

class Yuul {
	static val LOGGER = LoggerFactory.getLogger(Yuul)

	def static void main(String[] args) {
		LOGGER.info("Starting Yuul")
    	
		val yaml = new Yaml()
		val input = new FileInputStream(new File("yuul.yam"))
		val Map<String, Object> yuul = yaml.load(input) as Map<String, Object>

		val processOtp = new ProcessOtp(yuul)
		processOtp.start

		var String readerName = null
		if (args.length > 0) {
			readerName = args.last
		}
		var nrs = new NfcReaderService(readerName)
		if (nrs == null) {
			LOGGER.error("no reader found")
			return
		}
		nrs.addCallback(new ReadYubiKeyOtp(processOtp.otpQeuue))
		nrs.start()
		while (true) {
			Thread.sleep(3600000)
		}
	}

	def static byte[] asBytes(int[] in) {
		val my = new ByteArrayOutputStream
		in.forEach[i|my.write(i)]
		return my.toByteArray
	}

	def static String asString(int[] in) {
		return asString(asBytes(in))
	}

	def static String asString(byte[] in) {
		val boas = new ByteArrayOutputStream()
		val out = new PrintStream(boas)
		in.forEach[i|out.printf("%02x ", i)]
		return boas.toString()
	}

}
