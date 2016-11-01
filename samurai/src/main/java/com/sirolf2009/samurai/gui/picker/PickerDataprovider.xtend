package com.sirolf2009.samurai.gui.picker

import com.sirolf2009.samurai.Registered
import com.sirolf2009.samurai.Registered.Registration
import com.sirolf2009.samurai.Samurai
import com.sirolf2009.samurai.dataprovider.DataProvider
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
import java.util.function.Supplier

class PickerDataprovider extends TitledPane {

	@Accessors val providerProperty = new SimpleObjectProperty<Supplier<DataProvider>>(this, "provider")
	@Accessors val satisfiedProperty = new SimpleBooleanProperty(this, "satisfied", false)

	new() {
		super("Data", null)
		expanded = false
		satisfiedProperty.bind(providerProperty.notNull)
		satisfiedProperty.addListener[
			if((it as ObservableBooleanValue).get()) {
				graphic = new ImageView(new Image(Samurai.getResourceAsStream("/ok.png")))
			} else {
				graphic = null
			}
		]
		
		content = new TreeView => [
			root = new TreeItem("Data Provider") => [root|
				Registered.dataProviders.groupBy[type].entrySet.forEach[
					val providers = value
					root.children += new TreeItem(key) => [type|
						providers.forEach[
							type.children += new TreeItem(it)
						]
					]
				]
			]
			showRoot = false
			selectionModel.selectedItemProperty.addListener [
				val item = (it as ReadOnlyObjectProperty<TreeItem<?>>).value
				if(item.value instanceof Registration<?>) {
					providerProperty.set([(item.value as Registration<DataProvider>).clazz.newInstance])
				} else {
					providerProperty.set(null)
				}
			]
			expandAllNodes
		]
	}

}
