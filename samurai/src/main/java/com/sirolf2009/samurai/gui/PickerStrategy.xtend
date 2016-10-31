package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.Samurai
import com.sirolf2009.samurai.annotations.Register
import com.sirolf2009.samurai.strategy.IStrategy
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.scene.control.TitledPane
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import org.eclipse.xtend.lib.annotations.Accessors
import org.reflections.Reflections
import org.reflections.scanners.SubTypesScanner
import org.reflections.scanners.TypeAnnotationsScanner

import static extension com.sirolf2009.samurai.util.GUIUtil.*

class PickerStrategy extends TitledPane {

	@Accessors val strategyProperty = new SimpleObjectProperty<IStrategy>(this, "strategy")
	@Accessors val satisfiedProperty = new SimpleBooleanProperty(this, "satisfied", false)

	new() {
		super("Strategy", null)
		expanded = false
		content = new TreeView => [
			root = new TreeItem("Strategy") => [
				children += new TreeItem("Built-In") => [
					val reflections = new Reflections("", new SubTypesScanner(), new TypeAnnotationsScanner())
					reflections.getTypesAnnotatedWith(Register).filter[interfaces.findFirst[IStrategy.isAssignableFrom(it)] != null].forEach [ strategyClass |
						val name = (strategyClass.annotations.findFirst[annotationType == Register] as Register).name
						val strategy = strategyClass.newInstance() as IStrategy
						children += new TreeItemStrategy(name, strategy)
					]
				]
			]
			showRoot = false
			selectionModel.selectedItemProperty.addListener [
				val item = (it as ReadOnlyObjectProperty<TreeItem<String>>).value
				if(item instanceof TreeItemStrategy) {
					strategyProperty.set(item.strategy)
					satisfiedProperty.set(true)
					graphic = new ImageView(new Image(Samurai.getResourceAsStream("/ok.png")))
				} else {
					strategyProperty.set(null)
					satisfiedProperty.set(false)
					graphic = null
				}
			]
			expandAllNodes
		]
	}
}
