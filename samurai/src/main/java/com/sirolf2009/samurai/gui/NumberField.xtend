package com.sirolf2009.samurai.gui

import javafx.scene.control.TextField
import javafx.scene.control.TextFormatter
import javafx.util.converter.NumberStringConverter

class NumberField extends TextField {
	
	new() {
		super()
		textFormatter = new TextFormatter(new NumberStringConverter())
		this.text = 0+""
	}
	
	new(double initial) {
		super(initial+"")
		textFormatter = new TextFormatter(new NumberStringConverter())
		this.text = initial+""
	}
	
	def getNumber() {
		return Double.parseDouble(text)
	}
	
}