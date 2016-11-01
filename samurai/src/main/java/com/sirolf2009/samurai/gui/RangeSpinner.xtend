package com.sirolf2009.samurai.gui

import javafx.scene.layout.GridPane
import javafx.scene.control.Label

class RangeSpinner extends GridPane {

	new(double min, double max, double step) {
		add(new Label("From"), 0, 0)
		add(new NumberSpinner(min, step), 1, 0)
		add(new Label("To"), 0, 1)
		add(new NumberSpinner(max, step), 1, 1)
		add(new Label("Step"), 0, 2)
		add(new NumberSpinner(step, step), 1, 2)
	}
	
}