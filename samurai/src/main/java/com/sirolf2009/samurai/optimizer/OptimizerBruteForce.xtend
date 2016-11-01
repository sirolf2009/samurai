package com.sirolf2009.samurai.optimizer

import com.sirolf2009.samurai.gui.RangeSpinner
import com.sirolf2009.samurai.gui.picker.PickerOptimizerParameters
import com.sirolf2009.samurai.strategy.IStrategy
import com.sirolf2009.samurai.strategy.Param
import javafx.scene.control.Label
import javafx.scene.layout.GridPane
import com.sirolf2009.samurai.annotations.Register

@Register(name="Brute Force", type="Built-In")
class OptimizerBruteForce implements IOptimizer {

	override populateParameters(PickerOptimizerParameters parameterPane, IStrategy strategy) {
		val root = new GridPane()
		root.hgap = 4
		root.vgap = 4
		parameterPane.content = root
		strategy.class.fields.filter [
			annotations.findFirst[it.annotationType == Param] != null
		].forEach [ field, index |
			root.add(new Label(field.name), 0, index)
			if(field.type == Integer || field.type == Integer.TYPE) {
				root.add(new RangeSpinner(field.get(strategy) as Integer, field.get(strategy) as Integer, 1), 1, index)
			}
		]
	}

	override canOptimize(IStrategy strategy) {
		return true
	}

}
