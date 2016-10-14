package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.dataprovider.DataProvider
import javafx.scene.Node
import javafx.scene.control.TreeItem
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.function.Supplier

class TreeItemDataProvider extends TreeItem<String> {
	
	@Accessors val Supplier<DataProvider> provider
	
	new(String name, Supplier<DataProvider> provider) {
		super(name)
		this.provider = provider
	}
	
	new(String name, Node graphic, Supplier<DataProvider> provider) {
		super(name, graphic)
		this.provider = provider
	}
	
}