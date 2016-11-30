package com.sirolf2009.samurai.renderer.chart

import com.sirolf2009.samurai.renderer.RendererDefault
import eu.verdelhan.ta4j.TimeSeries
import java.util.List
import javafx.geometry.BoundingBox
import javafx.geometry.Point2D
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext
import org.eclipse.xtend.lib.annotations.Accessors

import static com.sirolf2009.samurai.renderer.chart.ChartSettings.*

class ChartScatter extends Chart {

	static val renderer = new RendererDefault()

	val TimeSeries timeseries
	@Accessors val List<Point2D> vectors
	val extension GraphicsContext g

	new(Canvas canvas, TimeSeries timeseries, List<Point2D> vectors) {
		super(canvas)
		this.timeseries = timeseries
		this.vectors = vectors
		this.g = canvas.graphicsContext2D
	}
	
	override draw() {
		save()
		clearScreen(g)
		val panelWidth = canvas.width - Y_AXIS_SIZE - AXIS_OFFSET
		val xList = vectors.filter[it != null].map[Double.valueOf(x)].toList()
		val yList = vectors.filter[it != null].map[Double.valueOf(y)].toList()
		val startX = xList.min()
		val endX = xList.max()

		if(startX == endX) {
			drawNoData()
		} else {
			val minPrice = yList.min()
			val maxPrice = yList.max()
			val axisY = NumberAxis.fromRange(minPrice, maxPrice, new BoundingBox(0, 0, Y_AXIS_SIZE, canvas.height - X_AXIS_SIZE - AXIS_OFFSET), true)
			val axisX = NumberAxis.fromRange(0, vectors.map[x].max, new BoundingBox(0, 0, canvas.width - Y_AXIS_SIZE - AXIS_OFFSET, X_AXIS_SIZE), false)

			renderer.drawScatterPlot(axisY, axisX, vectors, g, panelWidth, canvas.height - X_AXIS_SIZE - AXIS_OFFSET)
			translate(0, canvas.height - X_AXIS_SIZE - AXIS_OFFSET)
			
			renderer.drawXAxis(axisX, g)

			restore()
		}
	}
	
	override size() {
		timeseries.tickCount
	}
	
	override getRenderer() {
		renderer
	}
	
}