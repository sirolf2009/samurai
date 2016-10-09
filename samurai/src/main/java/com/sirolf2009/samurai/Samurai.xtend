package com.sirolf2009.samurai

import com.sirolf2009.samurai.dataprovider.DataProviderBitcoinCharts
import com.sirolf2009.samurai.gui.ResizableCanvas
import com.sirolf2009.samurai.gui.TreeItemDataProvider
import com.sirolf2009.samurai.renderer.chart.Chart
import com.sirolf2009.samurai.renderer.chart.ChartData
import com.sirolf2009.samurai.strategy.StrategySMACrossover
import com.sirolf2009.samurai.tasks.BackTest
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.TradingRecord
import java.io.FileInputStream
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.beans.value.ChangeListener
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.ProgressBar
import javafx.scene.control.TextField
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.image.Image
import javafx.scene.layout.AnchorPane
import javafx.scene.layout.GridPane
import javafx.scene.layout.HBox
import javafx.scene.layout.VBox
import javafx.scene.paint.Color
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.Accessors
import org.joda.time.DateTime
import org.joda.time.Period
import xtendfx.FXApp

import static extension com.sirolf2009.samurai.util.GUIUtil.*
import static extension xtendfx.scene.SceneBuilder.*

@FXApp @Accessors class Samurai {

	val progressMessage = new Label()
	val progressIndicator = new ProgressBar(0)

	val canvas = new ResizableCanvas(400, 500)
	var BackTest backTest
	var Chart chart

	override void start(Stage it) {
		BorderedScene[
			bottom = new HBox(8, progressMessage, progressIndicator) => [
				alignment = Pos.BASELINE_RIGHT
			]

			val container = new AnchorPane(canvas)
			container.minWidth = 0
			container.minHeight = 0
			canvas.widthProperty.bind(container.widthProperty())
			canvas.heightProperty.bind(container.heightProperty())
			val ChangeListener<? super Number> onResize = [
				if(chart != null) {
					chart.draw()
				} else {
					drawIcon()
				}
			]
			container.widthProperty().addListener(onResize)
			container.heightProperty().addListener(onResize)
			AnchorPane.setBottomAnchor(canvas, 0D)
			AnchorPane.setTopAnchor(canvas, 0D)
			AnchorPane.setLeftAnchor(canvas, 0D)
			AnchorPane.setRightAnchor(canvas, 0D)
			center = container
			left = new VBox(new TreeView => [
				root = new TreeItem("Symbol") => [
					children += new TreeItem("BitcoinCharts") => [
						children += new TreeItemDataProvider("BTCCNY - OkCoin", new DataProviderBitcoinCharts("data/okcoinCNY.csv"))
						children += new TreeItemDataProvider("BTCUSD - OkCoin", new DataProviderBitcoinCharts("data/bitfinexUSD.csv"))
						children += new TreeItemDataProvider("BTCUSD - Bitstamp", new DataProviderBitcoinCharts("data/bitstampUSD.csv"))
					]
				]
				selectionModel.selectedItemProperty.addListener [
					val node = (it as ReadOnlyObjectProperty<TreeItem<String>>).value
					if(node instanceof TreeItemDataProvider) {
						val provider = (node as TreeItemDataProvider).provider
						provider => [
							period = new Period(1000 * 60 * 60)
							from = new DateTime(0)
							to = new DateTime(System.currentTimeMillis)
							progressMessage.textProperty.bind(messageProperty)
							progressIndicator.progressProperty.bind(progressProperty)
						]
						new Thread(provider).start()

						provider.onSucceeded = [
							backTest = new BackTest(this, new StrategySMACrossover(), it.source.value as TimeSeries)

							progressMessage.textProperty.bind(backTest.messageProperty)
							progressIndicator.progressProperty.bind(backTest.progressProperty)

							backTest.onSucceeded = [
								chart = new Chart(this, backTest.series, it.source.value as TradingRecord, new ChartData(backTest.series, backTest.strategy.indicators(backTest.series)))
								chart.draw()
							]
							new Thread(backTest).start()
						]
					}
				]
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
		icons += new Image(new FileInputStream("src/main/resources/icon.png"))
		show
	}
	
	def drawIcon() {
		val g = canvas.graphicsContext2D
		g.fill = Color.BLACK.brighter
		g.fillRect(0, 0, canvas.width, canvas.height)
		val image = new Image(new FileInputStream("src/main/resources/icon.png"))
		g.drawImage(image, canvas.width/2-image.width/2, canvas.height/2-image.height/2)
	}

}
