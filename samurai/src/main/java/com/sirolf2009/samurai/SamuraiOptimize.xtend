package com.sirolf2009.samurai

import com.sirolf2009.samurai.gui.SetupOptimize
import javafx.geometry.Insets
import javafx.scene.control.Button
import javafx.scene.control.ScrollPane
import javafx.scene.control.Tab
import javafx.scene.control.TabPane
import javafx.scene.image.Image
import javafx.scene.layout.Background
import javafx.scene.layout.BackgroundFill
import javafx.scene.layout.BackgroundImage
import javafx.scene.layout.BackgroundPosition
import javafx.scene.layout.BackgroundRepeat
import javafx.scene.layout.BackgroundSize
import javafx.scene.layout.BorderPane
import javafx.scene.layout.CornerRadii
import javafx.scene.layout.VBox
import javafx.scene.paint.Color

class SamuraiOptimize extends BorderPane {

	val SetupOptimize optimizeSetup

	new(Samurai samurai) {
		val optimizations = new TabPane()
		val image = new BackgroundImage(new Image(Samurai.getResourceAsStream("/icon.png"), 157, 157, true, true), BackgroundRepeat.NO_REPEAT, BackgroundRepeat.NO_REPEAT, BackgroundPosition.CENTER, BackgroundSize.DEFAULT)
		optimizations.background = new Background(#[new BackgroundFill(Color.BLACK.brighter, new CornerRadii(0), new Insets(0))], #[image])
		center = optimizations
		
		optimizeSetup = new SetupOptimize()
		left = new ScrollPane(new VBox(
			optimizeSetup,
			new Button("Run Optimization") => [
				disableProperty.bind(optimizeSetup.optimizeSetupProperty.^null)
				onAction = [
					val setup = optimizeSetup.optimizeSetupProperty.get
					val tab = new Tab(setup.optimizer+"")
					optimizations.tabs += tab
					setup.optimizer.optimize(setup, optimizeSetup.pickerParameters, tab, samurai.statusBar)
				]
			]
		))
	}

}
