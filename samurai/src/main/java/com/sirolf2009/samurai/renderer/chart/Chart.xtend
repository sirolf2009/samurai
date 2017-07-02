package com.sirolf2009.samurai.renderer.chart

import com.sirolf2009.samurai.renderer.IRenderer
import eu.verdelhan.ta4j.Tick
import java.util.List
import javafx.geometry.BoundingBox
import javafx.geometry.Bounds
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext
import javafx.scene.input.MouseButton
import javafx.scene.input.MouseEvent
import javafx.scene.paint.Color
import javafx.scene.text.TextAlignment
import org.eclipse.xtend.lib.annotations.Accessors

import static com.sirolf2009.samurai.renderer.chart.ChartSettings.*

@Accessors abstract class Chart {

	val Canvas canvas

	var DragDetector dragDetector
	var int scrollX
	var double scaleX

	var Bounds xAxisBounds

	new(Canvas canvas) {
		this.canvas = canvas
		scrollX = 0
		scaleX = 1

		calculateXAxisBounds()

		canvas.widthProperty.addListener [
			calculateXAxisBounds()
			draw()
		]

		canvas.heightProperty.addListener [
			calculateXAxisBounds()
			draw()
		]

		canvas.onMousePressed = [
			if(button == MouseButton.PRIMARY) {
				dragDetector = if(xAxisBounds.contains(x, y)) {
					new ZoomXDetector(this, sceneX)
				} else {
					new PanDetector(this, sceneX, scrollX)
				}
			}
		]
		canvas.onMouseDragged = [
			if(button == MouseButton.PRIMARY && dragDetector !== null) {
				dragDetector.onMouseEvent(it)
				draw()
			}
		]
	}

	def void draw()

	def int size()

	def IRenderer getRenderer()

	def clearScreen(extension GraphicsContext g) {
		fill = Color.BLACK.brighter()
		fillRect(0, 0, canvas.width, canvas.height)
	}

	def void fitAll() {
		val width = canvas.width - (Y_AXIS_SIZE + AXIS_OFFSET)
		val count = size()
		scaleX = Math.min(0.01, width / count / WIDTH_TICK)
		draw()
	}

	def calculateXAxisBounds() {
		xAxisBounds = new BoundingBox(Y_AXIS_SIZE + WIDTH_TICK / 2, canvas.height - X_AXIS_SIZE, 0, canvas.width - Y_AXIS_SIZE, X_AXIS_SIZE, 0)
	}

	def drawXAxis(GraphicsContext g, List<Tick> candles) {
		val from = candles.get(0).endTime
		val to = candles.last.endTime
		val axis = DateAxis.fromRange(from, to, xAxisBounds)
		renderer.drawXAxis(axis, g)
	}

	def drawNoData() {
		canvas.graphicsContext2D.fill = Color.WHITESMOKE
		canvas.graphicsContext2D.textAlign = TextAlignment.CENTER
		canvas.graphicsContext2D.fillText("No Data", canvas.width / 2, canvas.height / 2)
	}

	abstract static class DragDetector {

		def void onMouseEvent(MouseEvent event)

	}

	static class PanDetector extends DragDetector {

		val Chart chart
		val double startX
		var int scrollX

		new(Chart chart, double startX, int scrollX) {
			this.chart = chart
			this.startX = startX
			this.scrollX = scrollX
		}

		override onMouseEvent(MouseEvent event) {
			val newX = event.sceneX
			val delta = (startX - newX) * (1 / chart.scaleX)
			val ticks = Math.floor(Math.abs(delta)) as int
			val newScrollX = if(delta < 0) scrollX - ticks else scrollX + ticks
			chart.scrollX = Math.max(0, newScrollX)
		}

	}

	static class ZoomXDetector extends DragDetector {

		val Chart chart
		var double previousX

		new(Chart chart, double startX) {
			this.chart = chart
			this.previousX = startX
		}

		override onMouseEvent(MouseEvent event) {
			val newX = event.sceneX
			val delta = previousX - newX
			val ticks = Math.abs(delta) / X_ZOOM_SENSITIVITY
			val newZoomX = if(delta < 0) chart.scaleX + ticks else chart.scaleX - ticks
			chart.scaleX = Math.max(0.1, newZoomX)
			previousX = newX
		}

	}

}
