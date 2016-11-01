package com.sirolf2009.samurai

import com.sirolf2009.samurai.gui.SetupOptimize
import javafx.scene.control.TitledPane
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.layout.BorderPane
import javafx.scene.layout.VBox

import static extension com.sirolf2009.samurai.util.GUIUtil.*

class SamuraiOptimize extends BorderPane {

	val SetupOptimize optimizeSetup

	new(Samurai samurai) {
		optimizeSetup = new SetupOptimize()
		left = new VBox(
			optimizeSetup,
			new TitledPane("Optimizers", null) => [
				content = new TreeView() => [
					root = new TreeItem("Optimizers") => [
						children += new TreeItem("Parameters") => [
							children += new TreeItem("Brute force")
						]
					]
					showRoot = false
					expandAllNodes
				]
//				expandedProperty.bind(optimizeSetup.parametersPane.expandedProperty)
			]
		)
	}

}
