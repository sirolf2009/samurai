package com.sirolf2009.samurai.gui

import javafx.scene.canvas.Canvas

class ResizableCanvas extends Canvas {
	
	new(double width, double height) {
		this.width = width
		this.height = height
	}

	override isResizable() {
		return true
	}

	override prefWidth(double height) {
		return getWidth()
	}

	override prefHeight(double width) {
		return getHeight()
	}

}
