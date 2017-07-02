package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.dataprovider.DataProvider
import com.sirolf2009.samurai.gui.picker.PickerDataprovider
import com.sirolf2009.samurai.gui.picker.PickerOptimizer
import com.sirolf2009.samurai.gui.picker.PickerOptimizerParameters
import com.sirolf2009.samurai.gui.picker.PickerStrategy
import com.sirolf2009.samurai.gui.picker.PickerTimeframe
import com.sirolf2009.samurai.optimizer.IOptimizer
import com.sirolf2009.samurai.strategy.IStrategy
import java.time.Duration
import java.time.ZonedDateTime
import javafx.beans.InvalidationListener
import javafx.beans.property.SimpleObjectProperty
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data

@Accessors class SetupOptimize extends VBox {

	val SimpleObjectProperty<OptimizeSetup> optimizeSetupProperty = new SimpleObjectProperty<OptimizeSetup>(this, "optimizeSetup")

	val PickerDataprovider pickerDataProvider
	val PickerStrategy pickerStrategy
	val PickerOptimizer pickerOptimizer
	val PickerTimeframe pickerTimeframe
	val PickerOptimizerParameters pickerParameters

	new() {
		pickerDataProvider = new PickerDataprovider()
		pickerStrategy = new PickerStrategy()
		pickerOptimizer = new PickerOptimizer()
		pickerTimeframe = new PickerTimeframe()
		pickerParameters = new PickerOptimizerParameters(pickerOptimizer.optimizerProperty, pickerStrategy.strategyProperty)

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
			pickerDataProvider.expanded = false
			pickerStrategy.expanded = false
			pickerOptimizer.expanded = false
			pickerTimeframe.expanded = false
			pickerParameters.expanded = true
		]

		pickerDataProvider.expanded = true

		val InvalidationListener objectUpdater = [
			if(pickerDataProvider.providerProperty.get !== null && pickerStrategy.strategyProperty.get !== null && pickerTimeframe.getTimeframeProperty.get !== null) {
				val provider = pickerDataProvider.providerProperty.get().get() => [
					period = pickerTimeframe.periodProperty.get()
					from = pickerTimeframe.fromProperty.get()
					to = pickerTimeframe.toProperty.get()
				]
				optimizeSetupProperty.set(new OptimizeSetup(provider, pickerStrategy.strategyProperty.get, pickerOptimizer.optimizerProperty.get(), pickerTimeframe.periodProperty.get, pickerTimeframe.fromProperty.get, pickerTimeframe.toProperty.get))
			} else {
				optimizeSetupProperty.set(null)
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
		IOptimizer optimizer
		Duration period
		ZonedDateTime from
		ZonedDateTime to

	}

}
