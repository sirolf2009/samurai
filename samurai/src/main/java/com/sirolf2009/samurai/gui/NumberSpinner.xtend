package com.sirolf2009.samurai.gui

import javafx.geometry.Pos
import javafx.scene.control.Button
import javafx.scene.layout.HBox
import javafx.scene.layout.StackPane
import javafx.scene.layout.VBox
import javafx.scene.shape.LineTo
import javafx.scene.shape.MoveTo
import javafx.scene.shape.Path

import static extension xtendfx.beans.binding.BindingExtensions.*

class NumberSpinner extends HBox {

	val double ARROW_SIZE = 4
	val NumberField numberField

	new(double initial, double step) {
		numberField = new NumberField(initial)

		val arrowUp = new Path()
		arrowUp.getElements().addAll(new MoveTo(-ARROW_SIZE, 0), new LineTo(ARROW_SIZE, 0), new LineTo(0, -ARROW_SIZE), new LineTo(-ARROW_SIZE, 0))
		arrowUp.mouseTransparent = true

		val arrowDown = new Path()
		arrowDown.getElements().addAll(new MoveTo(-ARROW_SIZE, 0), new LineTo(ARROW_SIZE, 0), new LineTo(0, ARROW_SIZE), new LineTo(-ARROW_SIZE, 0))
		arrowUp.mouseTransparent = true

		val buttonHeight = numberField.heightProperty().subtract(3).divide(2);
		val spacing = numberField.heightProperty().subtract(2).subtract(buttonHeight.multiply(2))

		val buttons = new VBox()
		val incrementButton = new Button()
		incrementButton.prefWidthProperty -> numberField.heightProperty
		incrementButton.minWidthProperty -> numberField.heightProperty
		incrementButton.maxHeightProperty -> buttonHeight.add(spacing)
		incrementButton.prefHeightProperty -> buttonHeight.add(spacing)
		incrementButton.minHeightProperty -> buttonHeight.add(spacing)
		incrementButton.focusTraversable = false
        incrementButton.setOnAction[
        	numberField.text = (numberField.number+step)+""
        	consume()
        ]

		val incPane = new StackPane()
		incPane.getChildren().addAll(incrementButton, arrowUp)
		incPane.alignment = Pos.CENTER

		val decrementButton = new Button()
		decrementButton.prefWidthProperty -> numberField.heightProperty
		decrementButton.minWidthProperty -> numberField.heightProperty
		decrementButton.maxHeightProperty -> buttonHeight.add(spacing)
		decrementButton.prefHeightProperty -> buttonHeight.add(spacing)
		decrementButton.minHeightProperty -> buttonHeight.add(spacing)
		decrementButton.focusTraversable = false
        decrementButton.setOnAction[
        	numberField.text = (numberField.number-step)+""
        	consume()
        ]

		val decPane = new StackPane()
		decPane.getChildren().addAll(decrementButton, arrowDown)
		decPane.alignment = Pos.CENTER

		buttons.children.addAll(incPane, decPane)
		children.addAll(numberField, buttons)
	}
	
	def getNumber() {
		return Double.parseDouble(numberField.text)
	}

}
