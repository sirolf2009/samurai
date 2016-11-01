package com.sirolf2009.samurai

import com.sirolf2009.samurai.gui.SamuraiMenuBar
import com.sirolf2009.samurai.gui.SamuraiStatusBar
import javafx.scene.image.Image
import javafx.scene.layout.BorderPane
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.Accessors
import xtendfx.FXApp

import static java.lang.Thread.*

import static extension com.sirolf2009.samurai.util.GUIUtil.*
import static extension xtendfx.scene.SceneBuilder.*

@FXApp @Accessors class Samurai {

	val statusBar = new SamuraiStatusBar()
	var BorderPane root

	override void start(Stage it) {
		Registered.runRegistration()
		BorderedScene[
			root = it
			top = new SamuraiMenuBar(this)
			center = new SamuraiBacktest(this)
			bottom = statusBar
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
