package com.sirolf2009.samurai

import com.sirolf2009.samurai.dataprovider.DataProviderBitcoinCharts
import com.sirolf2009.samurai.gui.TabPaneBacktest
import com.sirolf2009.samurai.gui.TreeItemDataProvider
import com.sirolf2009.samurai.renderer.chart.Chart
import com.sirolf2009.samurai.strategy.StrategySMACrossover
import com.sirolf2009.samurai.tasks.BackTest
import java.io.FileInputStream
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.ProgressBar
import javafx.scene.control.TabPane
import javafx.scene.control.TextField
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.image.Image
import javafx.scene.layout.Background
import javafx.scene.layout.BackgroundImage
import javafx.scene.layout.BackgroundPosition
import javafx.scene.layout.BackgroundRepeat
import javafx.scene.layout.BackgroundSize
import javafx.scene.layout.GridPane
import javafx.scene.layout.HBox
import javafx.scene.layout.VBox
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.Accessors
import xtendfx.FXApp

import static extension com.sirolf2009.samurai.util.GUIUtil.*
import static extension xtendfx.scene.SceneBuilder.*
import javafx.scene.control.Tab
import javafx.scene.layout.BackgroundFill
import javafx.scene.paint.Color
import javafx.scene.layout.CornerRadii

@FXApp @Accessors class Samurai {

	val progressMessage = new Label()
	val progressIndicator = new ProgressBar(0)

	val backtests = new TabPane()

	var BackTest backTest
	var Chart chart

	override void start(Stage it) {
		BorderedScene[
			bottom = new HBox(8, progressMessage, progressIndicator) => [
				alignment = Pos.BASELINE_RIGHT
			]

			center = backtests
			val image = new BackgroundImage(new Image(new FileInputStream("src/main/resources/icon.png"), 157, 157, true, true), BackgroundRepeat.NO_REPEAT, BackgroundRepeat.NO_REPEAT, BackgroundPosition.CENTER, BackgroundSize.DEFAULT)
			backtests.background = new Background(#[new BackgroundFill(Color.BLACK.brighter, new CornerRadii(0), new Insets(0))], #[image])

			left = new VBox(new TreeView => [
				root = new TreeItem("Symbol") => [
					children += new TreeItem("BitcoinCharts") => [
						children += new TreeItemDataProvider("BTCCNY - OkCoin", new DataProviderBitcoinCharts("data/okcoinCNY.csv"))
						children += new TreeItemDataProvider("BTCUSD - OkCoin", new DataProviderBitcoinCharts("data/bitfinexUSD.csv"))
						children += new TreeItemDataProvider("BTCUSD - Bitstamp", new DataProviderBitcoinCharts("data/bitstampUSD.csv"))
					]
				]
				selectionModel.selectedItemProperty.addListener [
					val provider = ((it as ReadOnlyObjectProperty<TreeItem<String>>).value as TreeItemDataProvider).provider
					val strat = new StrategySMACrossover()
					backtests.tabs += new Tab(strat.class.simpleName, new TabPaneBacktest(this, provider, new StrategySMACrossover()))
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

}
