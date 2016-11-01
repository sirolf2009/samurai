package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.dataprovider.DataProvider
import javafx.scene.Node
import javafx.scene.control.TreeItem
import org.eclipse.xtend.lib.annotations.Accessors

class TreeItemDataProvider extends TreeItem<String> {
	
	@Accessors val DataProvider provider
	
	new(String name, DataProvider provider) {
		super(name)
		this.provider = provider
	}
	
	new(String name, Node graphic, DataProvider provider) {
		super(name, graphic)
		this.provider = provider
	}
	
}