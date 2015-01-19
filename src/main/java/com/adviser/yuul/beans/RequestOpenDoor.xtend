package com.adviser.yuul.beans

import org.eclipse.xtend.lib.annotations.Data

@Data
class RequestOpenDoor {
	String doorId
	String doorOtp
	String user
	String deviceId
	String deviceOtp
}