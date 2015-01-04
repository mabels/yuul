package com.adviser.yuul

interface State {
	def State execute(NfcReaderService nrs) 
}