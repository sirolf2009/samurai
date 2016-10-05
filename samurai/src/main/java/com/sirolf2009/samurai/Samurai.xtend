package com.sirolf2009.samurai

import com.sirolf2009.samurai.dataprovider.DataProviderBitcoinCharts
import com.sirolf2009.samurai.dataprovider.DataProviderTa4J
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
import javafx.scene.paint.Color
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.Accessors
import xtendfx.FXApp

import static extension com.sirolf2009.samurai.util.GUIUtil.*
import static extension xtendfx.scene.SceneBuilder.*

@FXApp @Accessors class Samurai {

	val progressMessage = new Label()
	val progressIndicator = new ProgressBar(0)
	
	val Canvas canvas = new Canvas(400, 500)

	override void start(Stage it) {
		BorderedScene[
			bottom = new HBox(8, progressMessage, progressIndicator) => [
				alignment = Pos.BASELINE_RIGHT
			]

			val container = new VBox(canvas)
			HBox.setHgrow(container, Priority.ALWAYS);
			canvas.widthProperty().bind(container.widthProperty());
			canvas.heightProperty().bind(container.heightProperty());
			center = container
			draw(canvas)
			canvas.widthProperty.addListener([draw(canvas)])
			canvas.heightProperty.addListener([draw(canvas)])
			left = new VBox(new TreeView => [
				root = new TreeItem("Symbol") => [
					children += new TreeItem("Ta4J") => [
						children += new TreeItemDataProvider("BTCUSD - Bitstamp", new DataProviderTa4J())
					]
					children += new TreeItem("BitcoinCharts") => [
						children += new TreeItemDataProvider("BTCCNY - OkCoin", new DataProviderBitcoinCharts("src/main/resources/okcoinCNY.csv"))
						children += new TreeItemDataProvider("BTCUSD - OkCoin", new DataProviderBitcoinCharts("src/main/resources/bitfinexUSD.csv"))
					]
				]
				selectionModel.selectedItemProperty.addListener(new BackTest(this))
				expandAllNodes
			], new GridPane() => [
				padding = new Insets(4)
				add(new Label("From"), 0, 0)
				add(new TextField(), 1, 0)
				add(new Label("To"), 0, 1)
				add(new TextField(), 1, 1)
				add(new Button("Run Backtest"), 1, 4)
			])
			right = new TreeView => [
				root = new TreeItem("Scripts") => [
					children += new TreeItem("Indicators") => [
						children += new TreeItem("ANN")
					]
					children += new TreeItem("Strategies") => [
						children += new TreeItem("ANNSimple")
					]
				]
			]
		]
		title = "Samurai"
		width = 800
		height = 600
		show
	}

	def draw(Canvas canvas) {
		val g = canvas.graphicsContext2D
		g.fill = Color.BLACK.brighter
		g.fillRect(0, 0, canvas.getWidth(), canvas.getHeight())
		g.fill = Color.WHITE
		g.fillText("Samurai is fucking awesome", 0, 10)
		
		g.fillText(canvas.width+"", canvas.width-40, 10)
		g.fillText(canvas.height+"", 0, canvas.height-10)
	}

}
