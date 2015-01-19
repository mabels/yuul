package com.adviser.yuul.beans

import org.eclipse.xtend.lib.annotations.Data
import java.util.UUID

@Data
class RequestRegisterDoor {
	UUID doorId
	String doorKey
}