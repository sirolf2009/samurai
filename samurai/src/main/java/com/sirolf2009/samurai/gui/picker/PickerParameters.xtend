package com.sirolf2009.samurai.gui.picker

import com.sirolf2009.samurai.strategy.Param
import java.beans.PropertyDescriptor
import javafx.beans.property.ObjectProperty
import javafx.collections.FXCollections
import javafx.scene.control.TitledPane
import org.controlsfx.control.PropertySheet
import org.controlsfx.property.BeanProperty

class PickerParameters extends TitledPane {

	new(ObjectProperty<? extends Object> objectProperty) {
		super("Parameters", null)
		expanded = false

		val parameters = new PropertySheet(FXCollections.observableArrayList())
		objectProperty.addListener [ observable |
			val it = (observable as ObjectProperty<? extends Object>).get
			parameters.items.clear()
			if(it != null) {
				it.class.declaredFields.filter [
					annotations.findFirst[it.annotationType == Param] != null
				].forEach [ field, index |
					parameters.items.add(new BeanProperty(it, new PropertyDescriptor(field.name, it.class)))
				]
			}
		]
		content = parameters
	}
}
