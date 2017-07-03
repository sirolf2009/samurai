package com.sirolf2009.samurai.util

import java.io.PrintWriter
import java.io.StringWriter
import javafx.concurrent.WorkerStateEvent
import javafx.event.EventHandler
import javafx.geometry.HPos
import javafx.geometry.VPos
import javafx.scene.Node
import javafx.scene.control.Alert
import javafx.scene.control.Alert.AlertType
import javafx.scene.control.ButtonType
import javafx.scene.control.Control
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.layout.ColumnConstraints
import javafx.scene.layout.GridPane
import javafx.scene.layout.Pane
import javafx.scene.layout.Priority
import javafx.scene.layout.Region
import javafx.scene.layout.RowConstraints
import javafx.application.Platform

class GUIUtil {

	def static <T> void expandAllNodes(TreeView<T> tree) {
		tree.root.expandAllNodes
	}

	def static <T> void expandAllNodes(TreeItem<T> item) {
		if(item !== null && !item.isLeaf) {
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
				n.setMaxSize(Double.MAX_VALUE, Double.MAX_VALUE)
				n.setStyle("-fx-background-color: whitesmoke; -fx-alignment: center;")
			}
			if(n instanceof Pane) {
				n.setMaxSize(Double.MAX_VALUE, Double.MAX_VALUE)
				n.setStyle("-fx-background-color: whitesmoke; -fx-alignment: center;")
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

	public static val showErrorDialog = new EventHandler<WorkerStateEvent> {

		override handle(WorkerStateEvent event) {
			event.source.exception.showErrorDialog
		}
	}

	/**
	 * @author http://code.makery.ch/blog/javafx-dialogs-official/
	 */
	def static void showErrorDialog(Throwable ex) {
		Platform.runLater [
			val alert = new Alert(AlertType.ERROR)
			alert.setTitle("Exception Dialog")
			alert.setHeaderText("You've hit a bug. I'm sorry :(")
			alert.setContentText(ex.class.simpleName + ": " + ex.localizedMessage)

			val sw = new StringWriter()
			val pw = new PrintWriter(sw)
			ex.printStackTrace(pw)
			val exceptionText = sw.toString()

			val label = new Label("The exception stacktrace was:")

			val textArea = new TextArea(exceptionText)
			textArea.setEditable(false)
			textArea.setWrapText(true)

			textArea.setMaxWidth(Double.MAX_VALUE)
			textArea.setMaxHeight(Double.MAX_VALUE)
			GridPane.setVgrow(textArea, Priority.ALWAYS)
			GridPane.setHgrow(textArea, Priority.ALWAYS)

			val expContent = new GridPane()
			expContent.setMaxWidth(Double.MAX_VALUE)
			expContent.add(label, 0, 0)
			expContent.add(textArea, 0, 1)

			alert.dialogPane.expandableContent = expContent

			val report = new ButtonType("Report")
			alert.buttonTypes += report

			alert.dialogPane.children.filter[it instanceof Label].forEach[(it as Label).setMinHeight(Region.USE_PREF_SIZE)]
			ex.printStackTrace()
			val result = alert.showAndWait()
			if(result == report) {
				// TODO send email
				println("//TODO send email")
			}
		]
	}

}
