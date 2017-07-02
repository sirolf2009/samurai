package com.sirolf2009.samurai.optimizer

import com.sirolf2009.samurai.annotations.Register
import com.sirolf2009.samurai.gui.DoubleRangeSpinner
import com.sirolf2009.samurai.gui.DoubleRangeSpinner.DoubleRange
import com.sirolf2009.samurai.gui.IntegerRangeSpinner
import com.sirolf2009.samurai.gui.IntegerRangeSpinner.IntegerRange
import com.sirolf2009.samurai.gui.SamuraiStatusBar
import com.sirolf2009.samurai.gui.SetupOptimize.OptimizeSetup
import com.sirolf2009.samurai.gui.picker.PickerOptimizerParameters
import com.sirolf2009.samurai.strategy.IStrategy
import com.sirolf2009.samurai.strategy.Param
import com.sirolf2009.samurai.tasks.BackTest
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.analysis.criteria.TotalProfitCriterion
import java.beans.PropertyDescriptor
import java.util.ArrayList
import java.util.List
import java.util.Optional
import java.util.concurrent.Executors
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.scene.control.Tab
import javafx.scene.control.TableColumn
import javafx.scene.control.TableView
import javafx.util.Callback
import org.controlsfx.control.PropertySheet
import org.controlsfx.control.PropertySheet.Item
import org.controlsfx.property.editor.AbstractPropertyEditor
import org.controlsfx.property.editor.DefaultPropertyEditorFactory
import org.controlsfx.property.editor.Editors
import org.controlsfx.property.editor.PropertyEditor
import org.eclipse.xtend.lib.annotations.Accessors

@Register(name="Brute Force", type="Built-In")
class OptimizerBruteForce implements IOptimizer {

	val List<Pair<Item, PropertyDescriptor>> parameters = new ArrayList()

	override optimize(OptimizeSetup setup, PickerOptimizerParameters parameterPane, Tab optimizationTab, SamuraiStatusBar statusBar) {
		val possibleValues = parameters.map [
			value -> (key.observableValue.get as SimpleObjectProperty<IntegerRange>).value.possibleValues
		]

		val table = new TableView<List<String>>()
		table.columnResizePolicy = TableView.CONSTRAINED_RESIZE_POLICY
		table.columns.add(new TableColumn<List<String>, String>("Fitness") => [
			cellValueFactory = [
				if(value !== null) {
					val list = value
					return new SimpleStringProperty(list.get(0))
				}
				return new SimpleStringProperty("")
			]
		])
		possibleValues.map[key.name].forEach [ it, index |
			table.columns.add(new TableColumn<List<String>, String>(it) => [
				cellValueFactory = [
					if(value !== null) {
						val list = value
						return new SimpleStringProperty(list.get(index + 1))
					}
					return new SimpleStringProperty("")
				]
			])
		]
		optimizationTab.content = table

		setup.dataProvider.onSucceeded = [
			val data = it.source.value as TimeSeries
			val executor = Executors.newFixedThreadPool(Runtime.runtime.availableProcessors - 1)
			possibleValues.allIntegerCombinations.forEach [
				executor.submit [
					val parameters = new ArrayList()
					forEach[
						key.writeMethod.invoke(setup.strategy, value.intValue)
						parameters.add(value.intValue + "")
					]
					val backtest = new BackTest(setup.strategy, data)
					new Thread(backtest).start()
					backtest.get() => [
						val criterion = new TotalProfitCriterion()
						val profit = criterion.calculate(data, it)
						parameters.add(0, profit + "")
						table.items.add(parameters)
					]
				]
			]
		]
		statusBar.task = setup.dataProvider
		new Thread(setup.dataProvider).start
	}

	def getAllDoubleCombinations(List<Pair<PropertyDescriptor, ArrayList<Double>>> possibleValues) {
		val possibilities = new ArrayList()
		getAllDoubleCombinations(possibleValues, 0, new ArrayList(), possibilities)
		return possibilities
	}

	def void getAllDoubleCombinations(List<Pair<PropertyDescriptor, ArrayList<Double>>> possibleValues, int index, List<Pair<PropertyDescriptor, Double>> soFar, List<List<Pair<PropertyDescriptor, Double>>> possibilities) {
		if(index >= possibleValues.size) {
			possibilities.add(soFar)
			return
		}

		val next = possibleValues.get(index)
		next.value.forEach [
			val newList = new ArrayList(soFar.size + 1)
			soFar.forEach[newList.add(it)]
			newList.add(next.key -> it)
			getAllDoubleCombinations(possibleValues, index + 1, newList, possibilities)
		]
	}

	def getAllIntegerCombinations(List<Pair<PropertyDescriptor, ArrayList<Integer>>> possibleValues) {
		val possibilities = new ArrayList()
		getAllIntegerCombinations(possibleValues, 0, new ArrayList(), possibilities)
		return possibilities
	}

	def void getAllIntegerCombinations(List<Pair<PropertyDescriptor, ArrayList<Integer>>> possibleValues, int index, List<Pair<PropertyDescriptor, Integer>> soFar, List<List<Pair<PropertyDescriptor, Integer>>> possibilities) {
		if(index >= possibleValues.size) {
			possibilities.add(soFar)
			return
		}

		val next = possibleValues.get(index)
		next.value.forEach [
			val newList = new ArrayList(soFar.size + 1)
			soFar.forEach[newList.add(it)]
			newList.add(next.key -> it)
			getAllIntegerCombinations(possibleValues, index + 1, newList, possibilities)
		]
	}

	override populateParameters(IStrategy strategy, PickerOptimizerParameters parameterPane) {
		parameters.clear()
		val parameters = new PropertySheet(FXCollections.observableArrayList())
		parameters.propertyEditorFactory = new RangePropertyEditorFactory()
		parameterPane.content = parameters
		strategy.class.declaredFields.filter [
			annotations.findFirst[it.annotationType == Param] !== null
		].forEach [ field, index |
			val descriptor = new PropertyDescriptor(field.name, strategy.class)
			val defaultValue = descriptor.readMethod.invoke(strategy) as Integer
			val inputField = if(field.type == Integer.TYPE) {
					new IntegerRangeItem(field.name, new IntegerRange(defaultValue, defaultValue, 0))
				} else if(field.type == Double.TYPE) {
					new DoubleRangeItem(field.name, new DoubleRange(defaultValue, defaultValue, 0))
				}
			this.parameters.add(inputField -> descriptor)
			parameters.items.add(inputField)
		]
	}

	override canOptimize(IStrategy strategy) {
		return true
	}

	override toString() {
		return "Brute Force"
	}

	@Accessors static class IntegerRangeItem implements Item {

		val String name
		val SimpleObjectProperty<IntegerRange> valueProperty

		new(String name, IntegerRange defaultValue) {
			this.name = name
			valueProperty = new SimpleObjectProperty(this, "value", defaultValue)
		}

		override getCategory() {
			return "Default"
		}

		override getDescription() {
			return ""
		}

		override getObservableValue() {
			return Optional.of(valueProperty)
		}

		override getType() {
			return Integer.TYPE
		}

		override getValue() {
			return valueProperty.get
		}

		override setValue(Object newValue) {
			valueProperty.set(newValue as IntegerRange)
		}

		override getPropertyEditorClass() {
			return Optional.of(IntegerRangeEditor)
		}

	}

	@Accessors static class DoubleRangeItem implements Item {

		val String name
		val SimpleObjectProperty<DoubleRange> valueProperty

		new(String name, DoubleRange defaultValue) {
			this.name = name
			valueProperty = new SimpleObjectProperty(this, "value", defaultValue)
		}

		override getCategory() {
			return "Default"
		}

		override getDescription() {
			return ""
		}

		override getObservableValue() {
			return Optional.of(valueProperty)
		}

		override getType() {
			return Integer.TYPE
		}

		override getValue() {
			return valueProperty.get
		}

		override setValue(Object newValue) {
			valueProperty.set(newValue as DoubleRange)
		}

		override getPropertyEditorClass() {
			return Optional.of(DoubleRangeEditor)
		}

	}

	static class IntegerRangeEditor extends AbstractPropertyEditor<IntegerRange, IntegerRangeSpinner> {

		new(Item property) {
			super(property, new IntegerRangeSpinner(0, 0, 0))
		}

		override protected getObservableValue() {
			return editor.valueProperty
		}

		override setValue(IntegerRange value) {
			editor.valueProperty.set(value)
		}

	}

	static class DoubleRangeEditor extends AbstractPropertyEditor<DoubleRange, DoubleRangeSpinner> {

		new(Item property) {
			super(property, new DoubleRangeSpinner(0, 0, 0))
		}

		override protected getObservableValue() {
			return editor.valueProperty
		}

		override setValue(DoubleRange value) {
			editor.valueProperty.set(value)
		}

	}

	static class RangePropertyEditorFactory implements Callback<Item, PropertyEditor<?>> {

		override call(Item item) {
			if(item.getPropertyEditorClass().isPresent()) {
				val ed = Editors.createCustomEditor(item)
				if(ed.isPresent()) return ed.get()
			}

			return new DefaultPropertyEditorFactory().call(item)
		}
	}

}
