package com.sirolf2009.samurai.gui.picker

import com.sirolf2009.samurai.Registered
import com.sirolf2009.samurai.Registered.Registration
import com.sirolf2009.samurai.Samurai
import com.sirolf2009.samurai.strategy.IStrategy
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.value.ObservableBooleanValue
import javafx.scene.control.TitledPane
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import org.eclipse.xtend.lib.annotations.Accessors

import static extension com.sirolf2009.samurai.util.GUIUtil.*

class PickerStrategy extends TitledPane {

	@Accessors val strategyProperty = new SimpleObjectProperty<IStrategy>(this, "strategy")
	@Accessors val satisfiedProperty = new SimpleBooleanProperty(this, "satisfied", false)

	new() {
		super("Strategy", null)
		expanded = false
		satisfiedProperty.bind(strategyProperty.notNull)
		satisfiedProperty.addListener[
			if((it as ObservableBooleanValue).get()) {
				graphic = new ImageView(new Image(Samurai.getResourceAsStream("/ok.png")))
			} else {
				graphic = null
			}
		]
		
		content = new TreeView => [
			root = new TreeItem("Strategy") => [root|
				Registered.strategies.groupBy[type].entrySet.forEach[
					val strategies = value
					root.children += new TreeItem(key) => [type|
						strategies.forEach[
							type.children += new TreeItem(it)
						]
					]
				]
			]
			showRoot = false
			selectionModel.selectedItemProperty.addListener [
				val item = (it as ReadOnlyObjectProperty<TreeItem<?>>).value
				if(item.value instanceof Registration<?>) {
					strategyProperty.set((item.value as Registration<IStrategy>).clazz.newInstance)
				} else {
					strategyProperty.set(null)
				}
			]
			expandAllNodes
		]
	}
}
