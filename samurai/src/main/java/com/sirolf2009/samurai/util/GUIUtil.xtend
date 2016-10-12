package com.sirolf2009.samurai.util

import javafx.geometry.HPos
import javafx.geometry.VPos
import javafx.scene.Node
import javafx.scene.control.Control
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.layout.ColumnConstraints
import javafx.scene.layout.GridPane
import javafx.scene.layout.Pane
import javafx.scene.layout.RowConstraints

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

	/**
	 * @author https://community.oracle.com/thread/2386973
	 */
	def static void showGridLines(GridPane grid) {
		// make all of the Controls and Panes inside the grid fill their grid cell, 
		// align them in the center and give them a filled background.
		// you could also place each of them in their own centered StackPane with 
		// a styled background to achieve the same effect.
		for (Node n : grid.getChildren()) {
			if(n instanceof Control) {
				val control = n as Control
				control.setMaxSize(Double.MAX_VALUE, Double.MAX_VALUE)
				control.setStyle("-fx-background-color: whitesmoke; -fx-alignment: center;")
			}
			if(n instanceof Pane) {
				val pane = n as Pane
				pane.setMaxSize(Double.MAX_VALUE, Double.MAX_VALUE)
				pane.setStyle("-fx-background-color: whitesmoke; -fx-alignment: center;")
			}
		}

		// style the grid so that it has a background and gaps around the grid and between the 
		// grid cells so that the background will show through as grid lines.
		grid.setStyle("-fx-background-color: whitesmoke; -fx-padding: 2; -fx-hgap: 2; -fx-vgap: 2;")
		// turn layout pixel snapping off on the grid so that grid lines will be an even width.
		grid.setSnapToPixel(false)
	}

	/**
	 * @author https://community.oracle.com/thread/2386973
	 */
	def static void stretchGrid(GridPane grid, int columns, int rows) {
		val columnConstraint = new ColumnConstraints()
		columnConstraint.setPercentWidth(100 / columns)
		columnConstraint.setHalignment(HPos.CENTER)
		(0 .. columns).forEach[grid.getColumnConstraints().add(it, columnConstraint)]
		val rowConstraint = new RowConstraints()
		rowConstraint.setPercentHeight(100 / rows)
		rowConstraint.setValignment(VPos.CENTER)
		(0 .. rows).forEach[grid.getRowConstraints().add(it, rowConstraint)]
	}

	def static Node getNodeByRowColumnIndex(GridPane gridPane, int row, int column) {
		gridPane.children.findFirst[GridPane.getRowIndex(it) == row && GridPane.getColumnIndex(it) == column]
	}

}
