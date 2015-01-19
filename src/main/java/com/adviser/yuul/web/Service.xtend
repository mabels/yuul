package com.adviser.yuul.web

import java.util.UUID
import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import com.adviser.yuul.beans.Door

class Service {
	def registerRelais(UUID doorId, String name, String otpKey) {
	}

	def List<Door> get_doors() {
	}

	def String registerApp(String user, String password, String deviceId) {
		val deviceOtpKey = user + deviceId /* + YuulWebKey*/ 
		deviceOtpKey
	}
	
	def openDoor(String doorId, String doorOtp, String user, String deviceId, String deviceOtp) {
		
	}

}
