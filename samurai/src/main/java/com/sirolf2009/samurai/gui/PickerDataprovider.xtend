package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.Registered
import com.sirolf2009.samurai.Samurai
import com.sirolf2009.samurai.dataprovider.DataProvider
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.scene.control.TitledPane
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import org.eclipse.xtend.lib.annotations.Accessors

import static extension com.sirolf2009.samurai.util.GUIUtil.*

class PickerDataprovider extends TitledPane {

	@Accessors val providerProperty = new SimpleObjectProperty<DataProvider>(this, "provider")
	@Accessors val satisfiedProperty = new SimpleBooleanProperty(this, "satisfied", false)

	new() {
		super("Data", null)
		expanded = false
		content = new TreeView => [
			root = new TreeItem("Data Provider") => [root|
				Registered.dataProviders.groupBy[type].entrySet.forEach[
					val providers = value
					root.children += new TreeItem(key) => [type|
						providers.forEach[
							type.children += new TreeItemDataProvider(name, clazz.newInstance)
						]
					]
				]
			]
			showRoot = false
			selectionModel.selectedItemProperty.addListener [
				val item = (it as ReadOnlyObjectProperty<TreeItem<String>>).value
				if(item instanceof TreeItemDataProvider) {
					providerProperty.set((item as TreeItemDataProvider).provider)
					satisfiedProperty.set(true)
					graphic = new ImageView(new Image(Samurai.getResourceAsStream("/ok.png")))
				} else {
					providerProperty.set(null)
					satisfiedProperty.set(false)
					graphic = null
				}
			]
			expandAllNodes
		]
	}

}
