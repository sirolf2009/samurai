package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.dataprovider.DataProvider
import com.sirolf2009.samurai.gui.picker.PickerDataprovider
import com.sirolf2009.samurai.gui.picker.PickerOptimizer
import com.sirolf2009.samurai.gui.picker.PickerParameters
import com.sirolf2009.samurai.gui.picker.PickerStrategy
import com.sirolf2009.samurai.gui.picker.PickerTimeframe
import com.sirolf2009.samurai.strategy.IStrategy
import javafx.beans.InvalidationListener
import javafx.beans.property.SimpleObjectProperty
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.joda.time.DateTime
import org.joda.time.Period

class SetupOptimize extends VBox {

	@Accessors val SimpleObjectProperty<OptimizeSetup> backtestSetupProperty = new SimpleObjectProperty<OptimizeSetup>(this, "backtestSetup")

	val PickerDataprovider pickerDataProvider
	val PickerStrategy pickerStrategy
	val PickerOptimizer pickerOptimizer
	val PickerTimeframe pickerTimeframe
	val PickerParameters pickerParameters

	new() {
		pickerDataProvider = new PickerDataprovider()
		pickerStrategy = new PickerStrategy()
		pickerOptimizer = new PickerOptimizer()
		pickerTimeframe = new PickerTimeframe()
		pickerParameters = new PickerParameters(pickerStrategy.strategyProperty)

		pickerDataProvider.providerProperty.addListener [
			if(pickerDataProvider.satisfiedProperty.get) {
				pickerDataProvider.expanded = false
				pickerStrategy.expanded = true
				pickerOptimizer.expanded = false
				pickerTimeframe.expanded = false
				pickerParameters.expanded = false
			}
		]
		pickerStrategy.strategyProperty.addListener [
			if(pickerStrategy.satisfiedProperty.get) {
				pickerDataProvider.expanded = false
				pickerStrategy.expanded = false
				pickerOptimizer.expanded = true
				pickerTimeframe.expanded = false
				pickerParameters.expanded = false
			}
		]
		pickerOptimizer.optimizerProperty.addListener [
			if(pickerOptimizer.satisfiedProperty.get) {
				pickerDataProvider.expanded = false
				pickerStrategy.expanded = false
				pickerOptimizer.expanded = false
				pickerTimeframe.expanded = true
				pickerParameters.expanded = false
			}
		]
		pickerTimeframe.timeframeProperty.addListener [
			if(pickerTimeframe.satisfiedProperty.get) {
				pickerDataProvider.expanded = false
				pickerStrategy.expanded = false
				pickerOptimizer.expanded = false
				pickerTimeframe.expanded = false
				pickerParameters.expanded = true
			}
		]

		pickerDataProvider.expanded = true

		val InvalidationListener objectUpdater = [
			if(pickerDataProvider.providerProperty.get != null && pickerStrategy.strategyProperty.get != null && pickerTimeframe.getTimeframeProperty.get != null) {
				val provider = pickerDataProvider.providerProperty.get().get() => [
					period = pickerTimeframe.periodProperty.get()
					from = pickerTimeframe.fromProperty.get()
					to = pickerTimeframe.toProperty.get()
				]
				backtestSetupProperty.set(new OptimizeSetup(provider, pickerStrategy.strategyProperty.get, pickerTimeframe.periodProperty.get, pickerTimeframe.fromProperty.get, pickerTimeframe.toProperty.get))
			} else {
				backtestSetupProperty.set(null)
			}
		]
		pickerDataProvider.providerProperty.addListener(objectUpdater)
		pickerStrategy.strategyProperty.addListener(objectUpdater)
		pickerTimeframe.getTimeframeProperty.addListener(objectUpdater)

		children.addAll(pickerDataProvider, pickerStrategy, pickerOptimizer, pickerTimeframe, pickerParameters)
	}

	@Data static class OptimizeSetup {

		DataProvider dataProvider
		IStrategy strategy
		Period period
		DateTime from
		DateTime to

	}

}