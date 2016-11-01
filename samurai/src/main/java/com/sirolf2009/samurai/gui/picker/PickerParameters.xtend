package com.sirolf2009.samurai.gui.picker

import com.sirolf2009.samurai.gui.NumberSpinner
import com.sirolf2009.samurai.strategy.Param
import javafx.beans.property.ObjectProperty
import javafx.beans.property.SimpleMapProperty
import javafx.scene.control.Label
import javafx.scene.control.TitledPane
import javafx.scene.layout.GridPane
import org.eclipse.xtend.lib.annotations.Accessors

class PickerParameters extends TitledPane {

	@Accessors val parameters = new SimpleMapProperty<String, Object>()

	new(ObjectProperty<? extends Object> objectProperty) {
		super("Parameters", null)
		expanded = false

		val parametersGrid = new GridPane()
		objectProperty.addListener [ observable |
			val it = (observable as ObjectProperty<? extends Object>).get
			parametersGrid.children.clear()
			if(it != null) {
				it.class.fields.filter [
					annotations.findFirst[it.annotationType == Param] != null
				].forEach [ field, index |
					parametersGrid.add(new Label(field.name), 0, index)
					if(field.type == Integer || field.type == Integer.TYPE) {
						parametersGrid.add(new NumberSpinner(field.get(it) as Integer, 1) => [
							onKeyTyped = [
								parameters.put(field.name, Integer.parseInt(text))
							]
						], 1, index)
					}
				]
			}
		]
		
		content = parametersGrid
	}
}
