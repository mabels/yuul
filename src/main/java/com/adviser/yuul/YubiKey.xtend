package com.adviser.yuul

import javax.smartcardio.Card
import javax.smartcardio.CardChannel
import javax.smartcardio.ResponseAPDU
import javax.smartcardio.CommandAPDU
import com.adviser.yuul.NfcReaderFactory.NfcReaderService.NfcCallback

import org.slf4j.Logger
import org.slf4j.LoggerFactory

import java.io.ByteArrayOutputStream
import java.io.PrintStream
import com.yubico.client.v2.YubicoClient
import com.yubico.client.v2.YubicoResponse
import com.yubico.client.v2.YubicoResponseStatus
import javax.naming.ldap.LdapContext
import javax.naming.ldap.InitialLdapContext
import javax.naming.directory.SearchControls

class YubiKey extends NfcCallback {
	static val LOGGER = LoggerFactory.getLogger(NfcCallback);

	val int clientId
	val String secretKey
	new(int _clientId, String _secretKey) {
		clientId = _clientId
		secretKey = _secretKey
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
		val YubiKey ref
		new(int[] _send, YubiKey _ref) {
			super(_send)
			ref = _ref
		}

		def getOtp(ResponseAPDU answer) {
			val byte[] r = answer.getData()
			val boas = new ByteArrayOutputStream()
			(7..r.length).forEach[i| boas.write(r.get(i))]
			return r.toString
		}
		
		def ldapLookup() {
			val ctx = new InitialLdapContext();
			val controls = new SearchControls();
			controls.setSearchScope(SearchControls.SUBTREE_SCOPE);
			val results = ctx.search("", "(objectclass=person)", controls);
            while (results.hasMore()) {
                val searchResult = results.next();
                val attributes = searchResult.getAttributes();
                val attr = attributes.get("cn");
                //val cn = attr.get();
                System.out.println(" Person Common Name = " + attributes.get("cn"));
                System.out.println(" Person Display Name = " + attributes.get("displayName"));
                System.out.println(" Person logonhours = " + attributes.get("logonhours"));
                System.out.println(" Person MemberOf = " + attributes.get("memberOf"));
            }
		}
	
		override def boolean respond(ResponseAPDU a) {
			val ret = super.respond(a)
			if(!ret) {
				return false
			}
			//00 43 D1 01 3F 55 04 6D 79 2E 79 75 62 69 63 6F .C..?U.my.yubico
			//2E 63 6F 6D 2F 6E 65 6F 2F 63 63 63 63 63 63 64 .com/neo/ccccccd
			//6A 63 66 75 6C 6E 72 72 69 72 65 6A 6A 67 74 62 jcfulnrrirejjgtb
			//65 63 76 76 63 64 6C 68 6A 76 69 75 66 62 69 72 ecvvcdlhjviufbir
			//63 62 76 62 75                                  cbvbu
			
			val client = YubicoClient.getClient(ref.clientId)
			val otp = getOtp(a)
			LOGGER.debug("otp="+otp)
   			val response = client.verify(getOtp(a))
		    if (response.getStatus() != YubicoResponseStatus.OK) {
		    	return false
		    }
		    return true
		}
	}

	val cmds = #[
		new SimpleExcept(#[0x00, 0xa4, 0x04, 0x00, 0x07, 0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01, 0x00]),
		new SimpleExcept(#[0x00, 0xA4, 0x00, 0x0c, 0x02, 0xE1, 0x04]),
		new ProcessUri(#[0x00, 0xb0, 0x00, 0x00, 0x00], this)
	]

	def byte[] asBytes(int[] in) {
		val my = new ByteArrayOutputStream
		in.forEach[i|my.write(i)]
		return my.toByteArray
	}

	def String asString(int[] in) {
		return asString(asBytes(in))
	}

	def String asString(byte[] in) {
		val boas = new ByteArrayOutputStream()
		val out = new PrintStream(boas)
		in.forEach[i|out.printf("%02x ", i)]
		return boas.toString()
	}

	def ResponseAPDU transmit(CardChannel cc, SimpleExcept se) {
		LOGGER.debug("Send>>" + asString(se.send))
		val answer = cc.transmit(new CommandAPDU(asBytes(se.send)));
		LOGGER.debug("Recv<<" + asString(answer.bytes))
		answer
	}

	override call(Card card, CardChannel cc) {
		cmds.forEach [ cmd |
			val ret = transmit(cc, cmd)
			if(!cmd.respond(ret)) {
				LOGGER.error("can not process APDU=" + asString(cmd.send))
				return
			}
		]
	}
}
