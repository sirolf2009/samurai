package com.sirolf2009.samurai

import javafx.scene.layout.BorderPane
import com.sirolf2009.samurai.gui.SimulationSetup
import javafx.scene.layout.VBox
import javafx.scene.control.TitledPane
import javafx.scene.control.TreeView
import javafx.scene.control.TreeItem
import static extension com.sirolf2009.samurai.util.GUIUtil.*

class SamuraiOptimize extends BorderPane {

	val SimulationSetup simulationSetup

	new(Samurai samurai) {
		simulationSetup = new SimulationSetup()
		left = new VBox(
			simulationSetup,
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
				expandedProperty.bind(simulationSetup.parametersPane.expandedProperty)
			]
		)
	}

}
