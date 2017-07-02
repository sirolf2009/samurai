package com.sirolf2009.samurai.renderer.chart

import com.sirolf2009.samurai.renderer.RendererDefault
import eu.verdelhan.ta4j.TimeSeries
import java.util.ArrayList
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext
import javafx.scene.paint.Color

import static com.sirolf2009.samurai.renderer.chart.ChartSettings.*

import static extension com.sirolf2009.samurai.renderer.chart.ChartData.*
import javafx.geometry.BoundingBox

class ChartPrice extends Chart {

	static val renderer = new RendererDefault()

	val TimeSeries series
	val ChartData data
	val extension GraphicsContext g

	new(Canvas canvas, TimeSeries series, ChartData data) {
		super(canvas)
		this.series = series
		this.data = data
		this.g = canvas.graphicsContext2D
	}

	override draw() {
		if(series !== null) {
			save()
			clearScreen(g)

			val hasIndicators = data.indicators.size != 0
			val panels = 2 + if(hasIndicators) data.indicators.map[key].max else 0 // price chart counts as 2, because it should be twice as big
			val heightPerPanel = (canvas.height - X_AXIS_SIZE - AXIS_OFFSET) / panels

			val panelWidth = canvas.width - Y_AXIS_SIZE - AXIS_OFFSET
			val widthCandleRendered = WIDTH_TICK * scaleX
			val startCandle = Math.min(Math.max(0, size() - 10), Math.max(0, Math.floor(scrollX / WIDTH_TICK))) as int
			val endCandle = Math.max(0, Math.min(data.timeseries.tickCount - 1, startCandle + Math.floor(panelWidth / widthCandleRendered) as int))
			val candles = if(startCandle == endCandle) #[] else (startCandle .. endCandle).map[data.timeseries.getTick(it)].toList()

			if(candles.empty) {
				drawNoData()
			} else {
				{
					val panelHeight = heightPerPanel * 2 - AXIS_OFFSET
					val minPrice = if(data.indicatorsInPanel(0).size > 0) Math.min(data.min(startCandle, endCandle), data.min(0, startCandle, endCandle)) else data.min(startCandle, endCandle)
					val maxPrice = if(data.indicatorsInPanel(0).size > 0) Math.max(data.max(startCandle, endCandle), data.max(0, startCandle, endCandle)) else data.max(startCandle, endCandle)
					val axis = NumberAxis.fromRange(minPrice, maxPrice, new BoundingBox(0, 0, Y_AXIS_SIZE, panelHeight), true)

					renderer.drawTimeseries(axis, data.timeseries, data.markers.filter[key == 0].map[value].toList(), g, canvas.width, heightPerPanel * 2, scrollX, scaleX, startCandle, endCandle)
					data.indicatorsInPanel(0).forEach [
						renderer.drawLineIndicator(axis, it, new ArrayList(), g, canvas.width, heightPerPanel * 2, scrollX, scaleX, startCandle, endCandle)
					]
					renderer.drawTrades(axis, data.timeseries, data.tradingrecord, g, canvas.width, heightPerPanel * 2, scrollX, scaleX, startCandle, endCandle)
					translate(0, heightPerPanel * 2)
				}
				if(panels > 2) {
					(1 .. panels - 2).forEach [ panel |
						g.stroke = Color.WHITE
						g.lineWidth = 2
						g.strokeLine(0, 0, canvas.width, 0)

						val panelHeight = heightPerPanel - AXIS_OFFSET
						val minPrice = data.indicatorsInPanel(panel).min(startCandle, endCandle)
						val maxPrice = data.indicatorsInPanel(panel).max(startCandle, endCandle)
						val axis = NumberAxis.fromRange(minPrice, maxPrice, new BoundingBox(0, 0, Y_AXIS_SIZE, panelHeight), true)
						data.indicatorsInPanel(panel).forEach [
							renderer.drawLineIndicator(axis, it, new ArrayList(), g, canvas.width, heightPerPanel, scrollX, scaleX, startCandle, endCandle)
						]
						g.translate(0, heightPerPanel)
					]
				}
				drawXAxis(g, candles)
				restore()
			}
		}
	}

	override size() {
		return series.tickCount
	}

	override getRenderer() {
		return renderer
	}

}
