package com.sirolf2009.samurai.renderer.chart

import com.sirolf2009.samurai.Samurai
import com.sirolf2009.samurai.renderer.RendererDefault
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.TradingRecord
import javafx.scene.canvas.Canvas
import javafx.scene.input.MouseButton
import javafx.scene.paint.Color
import javafx.scene.input.MouseEvent
import com.sirolf2009.samurai.renderer.IRenderer

class Chart {
	
	static val renderer = new RendererDefault()
	
	val Samurai samurai
	val TimeSeries series
	val TradingRecord tradingRecord
	val ChartData data
	val Canvas canvas
	
	var DragDetector dragDetector
	var int scrollX
	var double zoomX
	
	new(Samurai samurai, TimeSeries series, TradingRecord tradingRecord, ChartData data) {
		this.samurai = samurai
		this.series = series
		this.tradingRecord = tradingRecord
		this.data = data
		canvas = samurai.canvas
		scrollX = 0
		zoomX = 1
		
		canvas.onMousePressed = [
			if(button == MouseButton.PRIMARY) {
				dragDetector = new DragDetector(renderer, series, sceneX, scrollX)
			}
		]
		canvas.onMouseDragged = [
			if(button == MouseButton.PRIMARY) {
				scrollX = dragDetector.getScrollX(it)
				draw()
			}
		]
	}
	
	def draw() {
		if(series != null) {
			val g = canvas.graphicsContext2D
			g.save()
			g.fill = Color.BLACK.brighter
			g.fillRect(0, 0, canvas.width, canvas.height)

			renderer.drawChart(data, canvas, g, scrollX, zoomX)

			g.restore()
		}
	}
	
	static class DragDetector {
		
		val IRenderer renderer
		val TimeSeries series
		val double startX
		var int scrollX
		
		new(IRenderer renderer, TimeSeries series, double startX, int scrollX) {
			this.renderer = renderer
			this.series = series
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