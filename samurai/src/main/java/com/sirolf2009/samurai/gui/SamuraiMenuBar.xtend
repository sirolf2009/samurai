package com.sirolf2009.samurai.gui

import javafx.application.Platform
import javafx.scene.control.Alert
import javafx.scene.control.Alert.AlertType
import javafx.scene.control.Label
import javafx.scene.control.Menu
import javafx.scene.control.MenuBar
import javafx.scene.control.MenuItem
import javafx.scene.control.SeparatorMenuItem
import javafx.scene.layout.Region
import com.sirolf2009.samurai.Samurai
import com.sirolf2009.samurai.SamuraiOptimize
import com.sirolf2009.samurai.SamuraiBacktest

class SamuraiMenuBar extends MenuBar {

	new(Samurai samurai) {
		val menuFile = new Menu("File")
		menuFile.items += new Menu("Switch Workspace") => [
			items += new MenuItem("Backtest") => [onAction = [samurai.root.center = new SamuraiBacktest(samurai)]]
			items += new MenuItem("Optimize") => [onAction = [samurai.root.center = new SamuraiOptimize(samurai)]]
		]
		menuFile.items += new SeparatorMenuItem()
		menuFile.items += new MenuItem("Exit") => [
			onAction = [Platform.exit()]
		]

		menus += menuFile

		val menuHelp = new Menu("Help")
		menuHelp.items += new MenuItem("About") => [
			onAction = [
				val alert = new Alert(AlertType.INFORMATION)
				alert.setTitle("")
				alert.setHeaderText("About")
				alert.setContentText("Samurai is an open source project, started by sirolf2009. It is licensed under CC0-1.0.\nNeither sirolf2009 nor any other contributors are responsible for any trades that you make or don't make. Using this application is entirely on your own risk.\nThe code for this project can be found at https://github.com/sirolf2009/samurai\nYou may contact me at masterflappie@gmail.com")
				alert.dialogPane.children.filter[it instanceof Label].forEach[(it as Label).setMinHeight(Region.USE_PREF_SIZE)]
				alert.show()
			]
		]
		menus += menuHelp
	}

}
