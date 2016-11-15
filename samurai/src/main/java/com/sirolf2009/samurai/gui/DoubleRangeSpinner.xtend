package com.sirolf2009.samurai.gui

import java.util.ArrayList
import javafx.beans.InvalidationListener
import javafx.beans.property.SimpleObjectProperty
import javafx.scene.control.Label
import javafx.scene.control.Spinner
import javafx.scene.layout.GridPane
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data

class DoubleRangeSpinner extends GridPane {

	@Accessors val SimpleObjectProperty<DoubleRange> valueProperty

	val Spinner<Double> minField
	val Spinner<Double> maxField
	val Spinner<Double> stepField

	new(double min, double max, double step) {
		vgap = 4
		valueProperty = new SimpleObjectProperty(this, "range", new DoubleRange(min, max, step))

		minField = new Spinner<Double>(0, Integer.MAX_VALUE, min, 0.1)
		maxField = new Spinner<Double>(0, Integer.MAX_VALUE, max, 0.1)
		stepField = new Spinner<Double>(0, Integer.MAX_VALUE, step, 0.1)
		
		val InvalidationListener listener = [
			valueProperty.set(new DoubleRange(minField.value, maxField.value, stepField.value))
		]
		
		minField.valueProperty.addListener(listener)
		maxField.valueProperty.addListener(listener)
		stepField.valueProperty.addListener(listener)
		valueProperty.addListener[ //TODO
//			minField.valueProperty.set(valueProperty.get.min)
//			maxField.valueProperty.set(valueProperty.get.max)
//			stepField.valueProperty.set(valueProperty.get.step)
		]

		add(new Label("From"), 0, 0)
		add(minField, 1, 0)
		add(new Label("To"), 0, 1)
		add(maxField, 1, 1)
		add(new Label("Step"), 0, 2)
		add(stepField, 1, 2)
	}

	@Data static class DoubleRange {

		double min
		double max
		double step
		
		def possibleValues() {
			val list = new ArrayList()
			for(var i = min; i <= max; i += step) {
				list += i
			}
			return list
		}

	}

}
