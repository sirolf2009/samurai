package com.sirolf2009.samurai.renderer.chart

import com.sirolf2009.samurai.renderer.RendererDefault
import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.TradingRecord
import javafx.scene.canvas.Canvas
import javafx.scene.paint.Color

class ChartIndicator extends Chart {

	static val renderer = new RendererDefault()

	val Indicator<?> indicator
	val TradingRecord tradingRecord
	val ChartData data

	new(Canvas canvas, Indicator<?> indicator, TradingRecord tradingRecord, ChartData data) {
		super(canvas)
		this.indicator = indicator
		this.tradingRecord = tradingRecord
		this.data = data
	}

	override draw() {
		val g = canvas.graphicsContext2D
		g.save()
		g.fill = Color.BLACK.brighter
		g.fillRect(0, 0, canvas.width, canvas.height)

		renderer.drawLineIndicatorChart(indicator, g, canvas.width, canvas.height, scrollX, zoomX)

		g.restore()
	}
	
	override size() {
		return indicator.timeSeries.tickCount
	}

}
