package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.dataprovider.DataProvider
import com.sirolf2009.samurai.strategy.IStrategy
import javafx.beans.InvalidationListener
import javafx.beans.property.SimpleObjectProperty
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.joda.time.DateTime
import org.joda.time.Period

class SetupBacktest extends VBox {

	@Accessors val SimpleObjectProperty<BacktestSetup> backtestSetupProperty = new SimpleObjectProperty<BacktestSetup>(this, "backtestSetup")

	val PickerDataprovider pickerDataProvider
	val PickerStrategy pickerStrategy
	val PickerTimeframe pickerTimeframe
	val PickerParameters pickerParameters

	new() {
		pickerDataProvider = new PickerDataprovider()
		pickerStrategy = new PickerStrategy()
		pickerTimeframe = new PickerTimeframe()
		pickerParameters = new PickerParameters(pickerStrategy.strategyProperty)

		pickerDataProvider.satisfiedProperty.addListener [
			pickerDataProvider.expanded = false
			pickerStrategy.expanded = true
			pickerTimeframe.expanded = false
			pickerParameters.expanded = false
		]
		pickerStrategy.satisfiedProperty.addListener [
			pickerDataProvider.expanded = false
			pickerStrategy.expanded = false
			pickerTimeframe.expanded = true
			pickerParameters.expanded = false
		]
		pickerTimeframe.satisfiedProperty.addListener [
			pickerDataProvider.expanded = false
			pickerStrategy.expanded = false
			pickerTimeframe.expanded = false
			pickerParameters.expanded = true
		]

		pickerDataProvider.expanded = true

		val InvalidationListener objectUpdater = [
			if(pickerDataProvider.providerProperty.get != null && pickerStrategy.strategyProperty.get != null && pickerTimeframe.getTimeframeProperty.get != null) {
				val provider = pickerDataProvider.providerProperty.get().get() => [
					period = pickerTimeframe.periodProperty.get()
					from = pickerTimeframe.fromProperty.get()
					to = pickerTimeframe.toProperty.get()
				]
				backtestSetupProperty.set(new BacktestSetup(provider, pickerStrategy.strategyProperty.get, pickerTimeframe.periodProperty.get, pickerTimeframe.fromProperty.get, pickerTimeframe.toProperty.get))
			} else {
				backtestSetupProperty.set(null)
			}
		]
		pickerDataProvider.providerProperty.addListener(objectUpdater)
		pickerStrategy.strategyProperty.addListener(objectUpdater)
		pickerTimeframe.getTimeframeProperty.addListener(objectUpdater)

		children.addAll(pickerDataProvider, pickerStrategy, pickerTimeframe, pickerParameters)
	}

	@Data static class BacktestSetup {

		DataProvider dataProvider
		IStrategy strategy
		Period period
		DateTime from
		DateTime to

	}

}
