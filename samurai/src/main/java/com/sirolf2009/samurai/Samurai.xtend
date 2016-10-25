package com.sirolf2009.samurai

import com.sirolf2009.samurai.gui.SamuraiMenuBar
import javafx.geometry.Pos
import javafx.scene.control.Label
import javafx.scene.control.ProgressBar
import javafx.scene.image.Image
import javafx.scene.layout.HBox
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.Accessors
import xtendfx.FXApp

import static java.lang.Thread.*

import static extension com.sirolf2009.samurai.util.GUIUtil.*
import static extension xtendfx.scene.SceneBuilder.*
import javafx.scene.layout.BorderPane

@FXApp @Accessors class Samurai {

	val progressMessage = new Label()
	val progressIndicator = new ProgressBar(0)
	var BorderPane root

	override void start(Stage it) {
		BorderedScene[
			root = it
			top = new SamuraiMenuBar(this)
			center = new SamuraiBacktest(this)
			bottom = new HBox(8, progressMessage, progressIndicator) => [
				alignment = Pos.BASELINE_RIGHT
			]
		]
		title = "Samurai"
		width = 1366
		height = 768
		icons += new Image(Samurai.getResourceAsStream("/icon.png"))
		show

		Thread.defaultUncaughtExceptionHandler = [ t, e |
			e.showErrorDialog()
		]
	}

}
