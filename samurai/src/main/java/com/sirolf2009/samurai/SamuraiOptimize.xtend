package com.sirolf2009.samurai

import com.sirolf2009.samurai.gui.SetupOptimize
import javafx.scene.control.ScrollPane
import javafx.scene.layout.BorderPane
import javafx.scene.layout.VBox

class SamuraiOptimize extends BorderPane {

	val SetupOptimize optimizeSetup

	new(Samurai samurai) {
		optimizeSetup = new SetupOptimize()
		left = new ScrollPane(new VBox(
			optimizeSetup
		))
	}

}
