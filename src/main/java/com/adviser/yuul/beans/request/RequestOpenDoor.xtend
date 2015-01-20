package com.adviser.yuul.beans.request

import org.eclipse.xtend.lib.annotations.Data

@Data
class RequestOpenDoor {

	String doorId
	String doorOtp
	String user
	String deviceId
	String deviceOtp
}
