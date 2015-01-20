package com.adviser.yuul.beans.request

import java.util.UUID
import org.eclipse.xtend.lib.annotations.Data

@Data
class RequestRegisterDoor {

	UUID doorId
	String doorKey
}