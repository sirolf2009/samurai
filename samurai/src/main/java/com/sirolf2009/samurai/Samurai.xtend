package com.sirolf2009.samurai

import com.sirolf2009.samurai.dataprovider.DataProviderBitcoinCharts
import com.sirolf2009.samurai.gui.NumberField
import com.sirolf2009.samurai.gui.NumberSpinner
import com.sirolf2009.samurai.gui.TabPaneBacktest
import com.sirolf2009.samurai.gui.TreeItemDataProvider
import com.sirolf2009.samurai.gui.TreeItemStrategy
import com.sirolf2009.samurai.renderer.chart.Chart
import com.sirolf2009.samurai.strategy.IStrategy
import com.sirolf2009.samurai.strategy.Param
import com.sirolf2009.samurai.strategy.StrategySMACrossover
import com.sirolf2009.samurai.tasks.BackTest
import java.io.FileInputStream
import java.time.LocalDate
import java.util.Calendar
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.control.Button
import javafx.scene.control.DatePicker
import javafx.scene.control.Label
import javafx.scene.control.ProgressBar
import javafx.scene.control.Separator
import javafx.scene.control.Tab
import javafx.scene.control.TabPane
import javafx.scene.control.TitledPane
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.layout.Background
import javafx.scene.layout.BackgroundFill
import javafx.scene.layout.BackgroundImage
import javafx.scene.layout.BackgroundPosition
import javafx.scene.layout.BackgroundRepeat
import javafx.scene.layout.BackgroundSize
import javafx.scene.layout.CornerRadii
import javafx.scene.layout.GridPane
import javafx.scene.layout.HBox
import javafx.scene.layout.VBox
import javafx.scene.paint.Color
import javafx.stage.Stage
import org.eclipse.xtend.lib.annotations.Accessors
import xtendfx.FXApp

import static extension com.sirolf2009.samurai.util.GUIUtil.*
import static extension xtendfx.scene.SceneBuilder.*
import java.lang.Thread.UncaughtExceptionHandler

@FXApp @Accessors class Samurai {

	val progressMessage = new Label()
	val progressIndicator = new ProgressBar(0)

	val backtests = new TabPane()

	var BackTest backTest
	var Chart chart

	var TreeItemDataProvider provider
	var IStrategy strategy

	override void start(Stage it) {
		BorderedScene[
			bottom = new HBox(8, progressMessage, progressIndicator) => [
				alignment = Pos.BASELINE_RIGHT
			]

			center = backtests
			val image = new BackgroundImage(new Image(new FileInputStream("src/main/resources/icon.png"), 157, 157, true, true), BackgroundRepeat.NO_REPEAT, BackgroundRepeat.NO_REPEAT, BackgroundPosition.CENTER, BackgroundSize.DEFAULT)
			backtests.background = new Background(#[new BackgroundFill(Color.BLACK.brighter, new CornerRadii(0), new Insets(0))], #[image])

			val dataPane = new TitledPane("Data", null)
			val strategyPane = new TitledPane("Strategy", null)
			val parametersPane = new TitledPane("Parameters", null)
			val parametersGrid = new GridPane() => [
				padding = new Insets(4)
			]
			val runBacktest = new Button("Run Backtest") => [
//				disabledProperty -> dataPane.graphicProperty.isNull().or(strategyPane.graphicProperty.isNull())
				maxWidth = Double.MAX_VALUE
				onMouseClicked = [
					strategy.class.fields.filter [
						annotations.findFirst[it.annotationType == Param] != null
					].forEach [ it, index |
						val value = {
							val field = parametersGrid.getNodeByRowColumnIndex(index, 1)
							if(field instanceof NumberField) {
								(field as NumberField).number
							} else if(field instanceof NumberSpinner) {
								(field as NumberSpinner).number
							} else {
								null
							}
						}
						if(type == Integer || type == Integer.TYPE) {
							set(strategy, value.intValue)
						} else {
							set(strategy, value)
						}
					]
					backtests.tabs += new Tab(strategy.class.simpleName, new TabPaneBacktest(this, provider.provider.get(), strategy))
				]
			]

			left = new VBox(
				dataPane => [
					content = new TreeView => [
						root = new TreeItem("") => [
							children += new TreeItem("BitcoinCharts") => [
								children += new TreeItemDataProvider("BTCCNY - OkCoin", [new DataProviderBitcoinCharts("data/okcoinCNY.csv")])
								children += new TreeItemDataProvider("BTCUSD - OkCoin", [new DataProviderBitcoinCharts("data/bitfinexUSD.csv")])
								children += new TreeItemDataProvider("BTCUSD - Bitstamp", [new DataProviderBitcoinCharts("data/bitstampUSD.csv")])
							]
						]
						showRoot = false
						selectionModel.selectedItemProperty.addListener [
							provider = (it as ReadOnlyObjectProperty<TreeItem<String>>).value as TreeItemDataProvider
							dataPane.graphic = new ImageView(new Image(new FileInputStream("src/main/resources/ok.png")))
							dataPane.expanded = false
							strategyPane.expanded = true
							parametersPane.expanded = false
						]
						expandAllNodes
					]
				],
				strategyPane => [
					expanded = false
					content = new TreeView => [
						root = new TreeItem("Strategy") => [
							children += new TreeItem("Built-In") => [
								children += new TreeItemStrategy("SMA Crossover", new StrategySMACrossover())
							]
						]
						showRoot = false
						selectionModel.selectedItemProperty.addListener [
							strategy = ((it as ReadOnlyObjectProperty<TreeItem<String>>).value as TreeItemStrategy).strategy
							strategyPane.graphic = new ImageView(new Image(new FileInputStream("src/main/resources/ok.png")))
							dataPane.expanded = false
							strategyPane.expanded = false
							parametersPane.expanded = true

							strategy.class.fields.filter [
								annotations.findFirst[it.annotationType == Param] != null
							].forEach [ field, index |
								parametersGrid.add(new Label(field.name), 0, index)
								if(field.type == Integer || field.type == Integer.TYPE) {
									parametersGrid.add(new NumberSpinner(field.get(strategy) as Integer, 1), 1, index)
								}
							]
						]
						expandAllNodes
					]
				],
				parametersPane => [
					expanded = false
					content = new VBox(
						parametersGrid,
						new Separator(),
						new GridPane() => [
							val cal = Calendar.instance
							padding = new Insets(4)
							add(new Label("From"), 0, 0)
							add(new DatePicker(LocalDate.ofYearDay(cal.get(Calendar.YEAR), 1)), 1, 0)
							add(new Label("To"), 0, 1)
							add(new DatePicker(LocalDate.ofYearDay(cal.get(Calendar.YEAR), cal.get(Calendar.DAY_OF_YEAR) - 1)), 1, 1)
						]
					)
				],
				runBacktest
			)
		]
		title = "Samurai"
		width = 1366
		height = 768
		icons += new Image(new FileInputStream("src/main/resources/icon.png"))
		show
		
		Thread.defaultUncaughtExceptionHandler = [t,e|
			e.showErrorDialog()
		]
	}

}
