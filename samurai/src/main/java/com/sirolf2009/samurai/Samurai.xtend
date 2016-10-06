package com.sirolf2009.samurai

import com.sirolf2009.samurai.dataprovider.DataProviderBitcoinCharts
import com.sirolf2009.samurai.gui.TreeItemDataProvider
import com.sirolf2009.samurai.tasks.BackTest
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.canvas.Canvas
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.ProgressBar
import javafx.scene.control.TextField
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.layout.GridPane
import javafx.scene.layout.HBox
import javafx.scene.layout.Priority
import javafx.scene.layout.VBox
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.Accessors
import xtendfx.FXApp

import static extension com.sirolf2009.samurai.util.GUIUtil.*
import static extension xtendfx.scene.SceneBuilder.*

@FXApp @Accessors class Samurai {

	val progressMessage = new Label()
	val progressIndicator = new ProgressBar(0)
	
	val Canvas canvas = new Canvas(400, 500)
	val backTest = new BackTest(this)

	override void start(Stage it) {
		BorderedScene[
			bottom = new HBox(8, progressMessage, progressIndicator) => [
				alignment = Pos.BASELINE_RIGHT
			]

			val container = new VBox(canvas)
			HBox.setHgrow(container, Priority.ALWAYS)
			canvas.widthProperty().bind(container.widthProperty())
			canvas.heightProperty().bind(container.heightProperty())
			center = container
			canvas.widthProperty.addListener([backTest.draw()])
			canvas.heightProperty.addListener([backTest.draw()])
			left = new VBox(new TreeView => [
				root = new TreeItem("Symbol") => [
					children += new TreeItem("BitcoinCharts") => [
						children += new TreeItemDataProvider("BTCCNY - OkCoin", new DataProviderBitcoinCharts("data/okcoinCNY.csv"))
						children += new TreeItemDataProvider("BTCUSD - OkCoin", new DataProviderBitcoinCharts("data/bitfinexUSD.csv"))
						children += new TreeItemDataProvider("BTCUSD - Bitstamp", new DataProviderBitcoinCharts("data/bitstampUSD.csv"))
					]
				]
				selectionModel.selectedItemProperty.addListener(backTest)
				expandAllNodes
			], new GridPane() => [
				padding = new Insets(4)
				add(new Label("From"), 0, 0)
				add(new TextField(), 1, 0)
				add(new Label("To"), 0, 1)
				add(new TextField(), 1, 1)
				add(new Button("Run Backtest"), 1, 4)
			])
		]
		title = "Samurai"
		width = 800
		height = 600
		show
	}

}
