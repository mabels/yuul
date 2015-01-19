package com.adviser.yuul.beans

import org.eclipse.xtend.lib.annotations.Data

@Data
class RequestRegisterApp {
	String user
	String password
	String deviceId
}