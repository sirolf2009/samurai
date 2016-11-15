package com.sirolf2009.samurai.gui.picker

import com.sirolf2009.samurai.optimizer.IOptimizer
import com.sirolf2009.samurai.strategy.IStrategy
import javafx.beans.property.ObjectProperty
import javafx.scene.control.TitledPane

class PickerOptimizerParameters extends TitledPane {

	new(ObjectProperty<? extends IOptimizer> optimizerProperty, ObjectProperty<? extends IStrategy> strategyProperty) {
		super("Parameters", null)
		expanded = false
		
		optimizerProperty.addListener[
			val value = (it as ObjectProperty<? extends IOptimizer>).value
			value.populateParameters(strategyProperty.get(), this)
		]
	}

}