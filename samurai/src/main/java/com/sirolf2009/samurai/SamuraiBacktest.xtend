package com.sirolf2009.samurai

import com.sirolf2009.samurai.gui.NumberField
import com.sirolf2009.samurai.gui.NumberSpinner
import com.sirolf2009.samurai.gui.SimulationSetup
import com.sirolf2009.samurai.gui.TabPaneBacktest
import com.sirolf2009.samurai.strategy.Param
import javafx.geometry.Insets
import javafx.scene.control.Button
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

import static extension com.sirolf2009.samurai.util.GUIUtil.*

class SamuraiBacktest extends BorderPane {

	val backtests = new TabPane()
	val SimulationSetup simulationSetup = new SimulationSetup()

	new(Samurai samurai) {
		center = backtests
		val image = new BackgroundImage(new Image(Samurai.getResourceAsStream("/icon.png"), 157, 157, true, true), BackgroundRepeat.NO_REPEAT, BackgroundRepeat.NO_REPEAT, BackgroundPosition.CENTER, BackgroundSize.DEFAULT)
		backtests.background = new Background(#[new BackgroundFill(Color.BLACK.brighter, new CornerRadii(0), new Insets(0))], #[image])

		val runBacktest = new Button("Run Backtest") => [
			maxWidth = Double.MAX_VALUE
			onMouseClicked = [
				simulationSetup.strategy.class.fields.filter [
					annotations.findFirst[it.annotationType == Param] != null
				].forEach [ it, index |
					val value = {
						val field = simulationSetup.parametersGrid.getNodeByRowColumnIndex(index, 1)
						if(field instanceof NumberField) {
							(field as NumberField).number
						} else if(field instanceof NumberSpinner) {
							(field as NumberSpinner).number
						} else {
							null
						}
					}
					if(type == Integer || type == Integer.TYPE) {
						set(simulationSetup.strategy, value.intValue)
					} else {
						set(simulationSetup.strategy, value)
					}
				]
				val provider = simulationSetup.provider.provider.get() => [
					period = simulationSetup.timeframePicker.period
					from = simulationSetup.timeframePicker.from
					to = simulationSetup.timeframePicker.to
				]
				backtests.tabs += new Tab(simulationSetup.strategy.class.simpleName, new TabPaneBacktest(samurai, provider, simulationSetup.strategy))
			]
		]

		left = new VBox(
			simulationSetup,
			runBacktest
		)
	}

}
