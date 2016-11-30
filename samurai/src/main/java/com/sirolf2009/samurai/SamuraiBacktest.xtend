package com.sirolf2009.samurai

import com.sirolf2009.samurai.gui.SetupBacktest
import com.sirolf2009.samurai.gui.TabPaneBacktest
import javafx.geometry.Insets
import javafx.scene.control.Button
import javafx.scene.control.ScrollPane
import javafx.scene.control.Tab
import javafx.scene.control.TabPane
import javafx.scene.image.Image
import javafx.scene.layout.Background
import javafx.scene.layout.BackgroundFill
import javafx.scene.layout.BackgroundImage
import javafx.scene.layout.BackgroundPosition
import javafx.scene.layout.BackgroundRepeat
import javafx.scene.layout.BackgroundSize
import javafx.scene.layout.BorderPane
import javafx.scene.layout.CornerRadii
import javafx.scene.layout.VBox
import javafx.scene.paint.Color
import eu.verdelhan.ta4j.TimeSeries
import com.sirolf2009.samurai.tasks.BackTest
import eu.verdelhan.ta4j.TradingRecord

class SamuraiBacktest extends BorderPane {

	val backtests = new TabPane()

	new(Samurai samurai) {
		center = backtests
		val image = new BackgroundImage(new Image(Samurai.getResourceAsStream("/icon.png"), 157, 157, true, true), BackgroundRepeat.NO_REPEAT, BackgroundRepeat.NO_REPEAT, BackgroundPosition.CENTER, BackgroundSize.DEFAULT)
		backtests.background = new Background(#[new BackgroundFill(Color.BLACK.brighter, new CornerRadii(0), new Insets(0))], #[image])

		val setup = new SetupBacktest()
		left = new ScrollPane(new VBox(
			setup,
			new Button("Run Backtest") => [
				disableProperty.bind(setup.backtestSetupProperty.^null)
				onAction = [
					val backtestSetup = setup.backtestSetupProperty.get()
					samurai.statusBar.task = backtestSetup.dataProvider
					new Thread(backtestSetup.dataProvider).start()
					backtestSetup.dataProvider.onSucceeded = [
						val timeSeries = it.source.value as TimeSeries
						val backTest = new BackTest(backtestSetup.strategy, timeSeries)

						samurai.statusBar.task = backTest
						backTest.onSucceeded = [
							backtests.tabs += new Tab(backtestSetup.strategy.class.simpleName, new TabPaneBacktest(backtestSetup.strategy, source.value as TradingRecord, timeSeries))
						]
						new Thread(backTest).start()
					]
				]
			]
		))
	}

}
