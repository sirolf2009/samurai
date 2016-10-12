package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.strategy.IStrategy
import javafx.scene.Node
import javafx.scene.control.TreeItem
import org.eclipse.xtend.lib.annotations.Accessors

class TreeItemStrategy extends TreeItem<String> {
	
	@Accessors val IStrategy strategy
	
	new(String name, IStrategy strategy) {
		super(name)
		this.strategy = strategy
	}
	
	new(String name, Node graphic, IStrategy strategy) {
		super(name, graphic)
		this.strategy = strategy
	}
	
}