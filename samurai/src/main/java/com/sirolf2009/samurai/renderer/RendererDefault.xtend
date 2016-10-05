package com.sirolf2009.samurai.renderer

import eu.verdelhan.ta4j.Tick
import eu.verdelhan.ta4j.TimeSeries
import java.util.List
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext
import javafx.scene.paint.Color

class RendererDefault implements IRenderer {

	static val WIDTH_CANDLESTICK = 9
	static val WIDTH_WICK = 1
	static val SPACING = 2
	static val AXIS_SIZE = 24
	static val AXIS_OFFSET = 16

	override drawTimeSeries(TimeSeries series, Canvas canvas, GraphicsContext g, int x, double scaleX) {
		val canvasWidth = canvas.width - AXIS_SIZE - AXIS_OFFSET
		val canvasHeight = canvas.height - AXIS_SIZE - AXIS_OFFSET
		
		val widthCandleRendered = (WIDTH_CANDLESTICK + SPACING) * scaleX
		val startCandle = Math.floor(x / widthCandleRendered) as int
		val endCandle = startCandle + Math.floor(canvasWidth / widthCandleRendered) as int
		val candles = (startCandle .. endCandle).map[series.getTick(it)].toList()
		val minPrice = candles.min[a, b|a.minPrice.compareTo(b.minPrice)].minPrice.toDouble
		val maxPrice = candles.max[a, b|a.maxPrice.compareTo(b.maxPrice)].maxPrice.toDouble
		
		g.fill = Color.BLACK.brighter
		g.fillRect(0, 0, canvas.getWidth(), canvas.getHeight())
		
		g.save()
		g.translate(AXIS_SIZE+(AXIS_OFFSET/2), canvas.height-AXIS_SIZE-(AXIS_OFFSET/2))
		g.scale(scaleX, 1)

		candles.forEach [
			val yWick = map(it.maxPrice.toDouble, minPrice, maxPrice, 0, -canvasHeight+AXIS_SIZE)
			val lengthWick = map(it.minPrice.toDouble, minPrice, maxPrice, 0, -canvasHeight) - yWick

			val upper = it.openPrice.max(it.closePrice).toDouble
			val lower = it.openPrice.min(it.closePrice).toDouble
			val yBody = map(upper, minPrice, maxPrice, 0, -canvasHeight)
			val lengthBody = map(lower, minPrice, maxPrice, 0, -canvasHeight+AXIS_SIZE) - yBody
			
			drawCandlestick(g, bullish, yWick, lengthWick, yBody, lengthBody)
			
			g.translate(WIDTH_CANDLESTICK + SPACING, 0)
		]
		g.restore()
		
		drawYAxis(canvas, g, candles)
		drawXAxis(canvas, g, candles)
	}

	def drawCandlestick(GraphicsContext g, boolean bullish, double yWick, double lengthWick, double yBody, double lengthBody) {
		g.fill = Color.WHITE
		g.fillRect(Math.floor(WIDTH_CANDLESTICK / 2), yWick, WIDTH_WICK, lengthWick)
		g.fill = if(bullish) Color.GREEN else Color.RED
		g.fillRect(0, yBody, WIDTH_CANDLESTICK, lengthBody)
	}
	
	def drawYAxis(Canvas canvas, GraphicsContext g, List<Tick> candles) {
		g.fill = Color.WHITE
		g.fillRect(AXIS_SIZE-1, 0, 1, canvas.height-AXIS_SIZE)
	}
	
	def drawXAxis(Canvas canvas, GraphicsContext g, List<Tick> candles) {
		g.fill = Color.WHITE
		g.fillRect(AXIS_SIZE, canvas.height-AXIS_SIZE-1, canvas.width, 1)
	}

	def map(double x, double in_min, double in_max, double out_min, double out_max) {
		return out_min + ((out_max - out_min) / (in_max - in_min)) * (x - in_min)
	}

}
