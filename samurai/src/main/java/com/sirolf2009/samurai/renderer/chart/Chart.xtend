package com.sirolf2009.samurai.renderer.chart

import javafx.scene.canvas.Canvas
import javafx.scene.input.MouseButton
import javafx.scene.input.MouseEvent
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors abstract class Chart {
	
	val Canvas canvas
	
	var DragDetector dragDetector
	var int scrollX
	var double zoomX
	
	new(Canvas canvas) {
		this.canvas = canvas
		scrollX = 0
		zoomX = 1
		
		canvas.onMousePressed = [
			if(button == MouseButton.PRIMARY) {
				dragDetector = new DragDetector(sceneX, scrollX)
			}
		]
		canvas.onMouseDragged = [
			if(button == MouseButton.PRIMARY) {
				scrollX = dragDetector.getScrollX(it)
				draw()
			}
		]
	}
	
	def void draw()
	
	static class DragDetector {
		
		val double startX
		var int scrollX
		
		new(double startX, int scrollX) {
			this.startX = startX
			this.scrollX = scrollX
		}
		
		def getScrollX(MouseEvent event) {
			val newX = event.sceneX
			val delta = startX - newX
			val ticks = Math.floor(Math.abs(delta)) as int
			val newScrollX = if(delta < 0) scrollX-ticks else scrollX+ticks
			return Math.max(0, newScrollX)
		}
		
	}
	
}