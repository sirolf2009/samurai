package com.sirolf2009.samurai.gui.picker

import com.sirolf2009.samurai.Registered
import com.sirolf2009.samurai.Registered.Registration
import com.sirolf2009.samurai.Samurai
import com.sirolf2009.samurai.optimizer.IOptimizer
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

class PickerOptimizer extends TitledPane {

	@Accessors val optimizerProperty = new SimpleObjectProperty<IOptimizer>(this, "optimizer")
	@Accessors val satisfiedProperty = new SimpleBooleanProperty(this, "satisfied", false)

	new() {
		super("Optimizer", null)
		expanded = false
		satisfiedProperty.bind(optimizerProperty.notNull)
		satisfiedProperty.addListener[
			if((it as ObservableBooleanValue).get()) {
				graphic = new ImageView(new Image(Samurai.getResourceAsStream("/ok.png")))
			} else {
				graphic = null
			}
		]
		
		content = new TreeView => [
			root = new TreeItem("Optimizer") => [root|
				Registered.optimizers.groupBy[type].entrySet.forEach[
					val optimizers = value
					root.children += new TreeItem(key) => [type|
						optimizers.forEach[optimizer|
							type.children += new TreeItem(optimizer.clazz.newInstance)
						]
					]
				]
			]
			showRoot = false
			selectionModel.selectedItemProperty.addListener [
				val item = (it as ReadOnlyObjectProperty<TreeItem<?>>).value
				if(item.value instanceof Registration<?>) {
					optimizerProperty.set((item.value as Registration<IOptimizer>).clazz.newInstance)
				} else {
					optimizerProperty.set(null)
				}
			]
			expandAllNodes
		]
	}

}