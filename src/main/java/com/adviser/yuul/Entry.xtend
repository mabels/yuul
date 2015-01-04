package com.adviser.yuul

import java.util.Date

class Entry {
	var String title
	val long now = (new Date()).time
	
	new(String _title) {
		title = _title
	}
	
	def getTitle() {
		return title
	}
	
	def getNow() {
		now
	}
}
