package com.adviser.yuul

import java.util.Map
import java.util.Queue
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit

import org.slf4j.LoggerFactory

import com.yubico.client.v2.YubicoClient
import com.yubico.client.v2.YubicoResponseStatus

class ProcessOtp {
	static val LOGGER = LoggerFactory.getLogger(ProcessOtp);

	val Map<String, Object> yuul
	val Thread my
	var boolean stopped = false
	val otpQueue = new LinkedBlockingQueue<String>()

	new(Map<String, Object> _yuul) {
		yuul = _yuul
		my = new Thread(processor)
	}

	def Queue<String> getOtpQeuue() {
		return otpQueue
	}

	//	def ldapLookup() {
	//		val ctx = new InitialLdapContext();
	//		val controls = new SearchControls();
	//		controls.setSearchScope(SearchControls.SUBTREE_SCOPE);
	//		val results = ctx.search("", "(objectclass=person)", controls);
	//		while (results.hasMore()) {
	//			val searchResult = results.next();
	//			val attributes = searchResult.getAttributes();
	//
	//			//val attr = attributes.get("cn");
	//			//val cn = attr.get();
	//			System.out.println(" Person Common Name = " + attributes.get("cn"));
	//			System.out.println(" Person Display Name = " + attributes.get("displayName"));
	//			System.out.println(" Person logonhours = " + attributes.get("logonhours"));
	//			System.out.println(" Person MemberOf = " + attributes.get("memberOf"));
	//		}
	//	}
	def Runnable processor() {
		return new Runnable() {
			 override def void run() {
				while (!stopped) {
					val otp = otpQueue.poll(500, TimeUnit.MILLISECONDS)
					if (otp != null) {
						LOGGER.info("Start Process of OTP:" + otp)
						try {
							val clientId = yuul.get("ClientId") as Integer
							LOGGER.info("Using YubiKey.ClientID:" + clientId)

							val client = YubicoClient.getClient(clientId)
							val response = client.verify(otp)
							if (response.getStatus() != YubicoResponseStatus.OK) {
								LOGGER.error("yubico clientId(" + clientId + ") = " + otp + "=>" + response.getStatus())
							} else {
								LOGGER.info("yubico clientId(" + clientId + ") = " + otp + "=> OK")
							}
						} catch (Exception e) {
							LOGGER.error("ProcessOTP Error:", e)
						}
					}
				}
			}
		}
	}

	def start() {
		if (!my.alive) {
			my.start()
		}
	}

}
