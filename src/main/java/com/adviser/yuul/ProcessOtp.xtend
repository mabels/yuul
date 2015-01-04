package com.adviser.yuul

import java.util.Map
import java.util.Queue
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit

import org.slf4j.LoggerFactory

import com.yubico.client.v2.YubicoClient
import com.yubico.client.v2.YubicoResponseStatus
import javax.naming.directory.SearchControls
import java.util.Hashtable
import javax.naming.Context
import javax.naming.directory.InitialDirContext
import java.util.regex.Pattern
import javax.naming.directory.DirContext

class ProcessOtp {
	static val LOGGER = LoggerFactory.getLogger(ProcessOtp)

	val Map<String, Object> yuul
	val Thread my
	var boolean stopped = false
	val otpQueue = new LinkedBlockingQueue<OtpTransaction>()
	var DirContext ldapCtx = null

	new(Map<String, Object> _yuul) {
		yuul = _yuul
		my = new Thread(processor)
	}

	def Queue<OtpTransaction> getOtpQeuue() {
		return otpQueue
	}

	static def String substitutor(String in, Map<String, String> substs) {
		val String[] out = newArrayOfSize(1)
		out.set(0, in)
		substs.forEach[key, value|
			val p = Pattern.compile(Pattern.quote("{"+key+"}"))
			val m = p.matcher(out.get(0))
			val sb = new StringBuffer()
			while (m.find()) {
				m.appendReplacement(sb, value)
			}
			m.appendTail(sb)
			out.set(0, sb.toString)
		]
		return out.get(0)
	}

	def boolean verifyLdap(String keyId) {
		val controls = new SearchControls()
		controls.setSearchScope(SearchControls.SUBTREE_SCOPE)
		var baseDn = yuul.get("ldapBaseDn") as String
		if (baseDn == null) {
			baseDn = ""
		}
		val maps = #{"key" -> keyId }
		val search = ProcessOtp.substitutor(yuul.get("ldapSearch") as String, maps)
		LOGGER.debug("ldapBaseDn:"+baseDn+" key:"+keyId+" ldapSearch:"+search)
		val results = ldapCtx.search(baseDn, search, controls)
		while (results.hasMore()) {
			val searchResult = results.next()
			val attributes = searchResult.getAttributes()
			LOGGER.debug(
				" Person Common Name = " + attributes.get("cn") + 
				" Person Display Name = " + attributes.get("displayName") + 
				" Person MemberOf = " + attributes.get("memberOf"))
			return true
		}
		return false
	}

	def Runnable processor() {
		return new Runnable() {
			override def void run() {
				while (!stopped) {
					val entry = otpQueue.poll(500, TimeUnit.MILLISECONDS)
					if (entry != null) {
						LOGGER.debug("Start Process of OTP:" + entry)
						try {
							val clientId = yuul.get("ClientId") as Integer
							LOGGER.debug("Using YubiKey.ClientID:" + clientId)

							val client = YubicoClient.getClient(clientId)
							val response = client.verify(entry.otp)
							val key = YubicoClient.getPublicId(entry.otp)
							if (response.getStatus() != YubicoResponseStatus.OK) {
								LOGGER.error(
									"yubico clientId(" + clientId + ") = key(" + key + ") otp(" + entry.otp + ")=>" +
										response.getStatus())
							} else {
								LOGGER.debug("yubico clientId(" + clientId + ") = key(" + key + ") otp(" + entry.otp + ")=> OK")
								if (verifyLdap(key)) {
									LOGGER.info("key "+key+" found in ldap grant access")
								} else {
									LOGGER.info("key "+key+" not found in ldap deny access")
								}
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
		val env = new Hashtable()
		env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory")
		env.put(Context.PROVIDER_URL, yuul.get("ldapUrl"))
		env.put(Context.SECURITY_AUTHENTICATION, yuul.get("ldapSecurity"))
		LOGGER.debug("ldapConnection:" + yuul.get("ldapUrl") + " ldapSecurityMethod:" + yuul.get("ldapSecurity"))
		val bindUser = yuul.get("ldapBindUser") as String
		val bindPassword = yuul.get("ldapBindPassword") as String
		if (bindUser != null && bindPassword != null) {
			env.put(Context.SECURITY_PRINCIPAL, bindUser)
			env.put(Context.SECURITY_CREDENTIALS, bindPassword)
			LOGGER.debug("ldapBindUser:" + bindUser + " ldapBindPassword:" + bindPassword)
		}
		LOGGER.debug("starting InitialDirContext")
		ldapCtx = new InitialDirContext(env)
		LOGGER.debug("started InitialDirContext")
		if (!my.isAlive) {
			LOGGER.debug("starting LDAP-Thread")
			my.start()
			LOGGER.debug("started LDAP-Thread")
		}
		LOGGER.info("Started")
	}

}
