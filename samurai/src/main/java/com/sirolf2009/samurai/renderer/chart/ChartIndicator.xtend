package com.sirolf2009.samurai.renderer.chart

import com.sirolf2009.samurai.renderer.RendererDefault
import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.Indicator
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext

import static com.sirolf2009.samurai.renderer.chart.ChartSettings.*

import static extension com.sirolf2009.samurai.renderer.chart.ChartData.*

class ChartIndicator extends Chart {

	static val renderer = new RendererDefault()

	val Indicator<Decimal> indicator
	val ChartData data
	val extension GraphicsContext g

	new(Canvas canvas, Indicator<Decimal> indicator, ChartData data) {
		super(canvas)
		this.indicator = indicator
		this.data = data
		this.g = canvas.graphicsContext2D
	}

	override draw() {
		save()
		clearScreen(g)

		val panelWidth = canvas.width - Y_AXIS_SIZE - AXIS_OFFSET
		val widthCandleRendered = WIDTH_TICK * scaleX
		val startCandle = Math.min(Math.max(0, size() - 10), Math.max(0, Math.floor(scrollX / WIDTH_TICK))) as int
		val endCandle = Math.max(0, Math.min(indicator.timeSeries.tickCount - 1, startCandle + Math.floor(panelWidth / widthCandleRendered) as int))

		if(startCandle == endCandle) {
			drawNoData()
		} else {
			val minPrice = indicator.min(startCandle, endCandle)
			val maxPrice = indicator.max(startCandle, endCandle)
			val axis = NumberAxis.fromRange(minPrice, maxPrice, canvas.height - X_AXIS_SIZE - AXIS_OFFSET)

			renderer.drawLineIndicator(axis, indicator, data.markers.filter[key == 0].map[value].toList(), g, panelWidth, canvas.height - X_AXIS_SIZE - AXIS_OFFSET, scrollX, scaleX, startCandle, endCandle)
			translate(0, canvas.height - X_AXIS_SIZE - AXIS_OFFSET)

			val candles = (startCandle .. endCandle).map[indicator.timeSeries.getTick(it)].toList()
			drawXAxis(g, candles)

			restore()
		}
	}

	override size() {
		return indicator.timeSeries.tickCount
	}

	override getRenderer() {
		return renderer
	}

}
