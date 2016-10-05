package com.sirolf2009.samurai.util

import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView

class GUIUtil {
	
	def static <T> void expandAllNodes(TreeView<T> tree) {
		tree.root.expandAllNodes
	}
	
	def static <T> void expandAllNodes(TreeItem<T> item) {
		if(item != null && !item.isLeaf) {
			item.expanded = true
			item.children.forEach[expandAllNodes]
		}
	}
	
}