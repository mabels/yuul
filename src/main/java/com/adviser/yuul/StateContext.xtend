package com.adviser.yuul

import javax.smartcardio.TerminalFactory
import javax.smartcardio.CardTerminal
import javax.smartcardio.Card
import org.slf4j.LoggerFactory

class StateContext {
	
	static val LOGGER = LoggerFactory.getLogger(StateContext)
	
	val TerminalFactory terminalFactory = TerminalFactory.getDefault()
	var Card card
	val String readerName

	new(String _readerName) {
		readerName = _readerName
	}

	def String getReaderName() {
		readerName
	}

	def TerminalFactory getTerminalFactory() {
		terminalFactory
	}

	def CardTerminal getCardTerminal() {
		val list = terminalFactory.terminals().list()
		//LOGGER.debug("looking for terminal:" + getReaderName() + ":" + list.size)
		var CardTerminal cardTerminal = null
		if(list.size > 0) {
			if(getReaderName() == null) {
				cardTerminal = list.get(0)
			} else {
				cardTerminal = list.findFirst[i|getReaderName().equals(i.name)]
			}
		}
		if(cardTerminal == null) {
			Thread.sleep(500)
			throw new Exception("can't find getCardTerminal for this reader="+readerName)
		}
		cardTerminal
	}


	def Card getCard() {
		card
	}

	def setCard(Card _card) {
		card = _card
	}

}
