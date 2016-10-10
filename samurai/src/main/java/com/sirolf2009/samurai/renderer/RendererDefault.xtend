package com.sirolf2009.samurai.renderer

import com.sirolf2009.samurai.renderer.chart.ChartData
import com.sirolf2009.samurai.renderer.chart.NumberAxis
import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.Tick
import eu.verdelhan.ta4j.TimeSeries
import java.util.List
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext
import javafx.scene.paint.Color
import javafx.scene.text.Text
import javafx.scene.text.Font

class RendererDefault implements IRenderer {

	static val WIDTH_CANDLESTICK = 9
	static val WIDTH_WICK = 1
	static val SPACING = 2
	static val WIDTH_TICK = WIDTH_CANDLESTICK + SPACING
	static val AXIS_SIZE = 48
	static val AXIS_OFFSET = 16

	override drawChart(ChartData chart, Canvas canvas, GraphicsContext g, int x, double scaleX) {
		val panels = 2 + chart.indicators.size //price chart counts as 2, because it should be twice as big
		val heightPerPanel = canvas.height / panels
		
		drawTimeseries(chart.timeseries, g, canvas.width, heightPerPanel*2, x, scaleX)
		g.translate(0, heightPerPanel*2)
		chart.indicators.forEach[indicator,index|
			g.stroke = Color.WHITE
			g.lineWidth = 2
			g.strokeLine(0,0, canvas.width, 0)
			
			drawLineIndicator(indicator, g, canvas.width, heightPerPanel, x, scaleX)
			g.translate(0, heightPerPanel)
		]
	}

	def drawTimeseries(TimeSeries series, GraphicsContext g, double width, double height, int x, double scaleX) {
		g.setLineWidth(1)
		g.fill = Color.WHITE
		g.fillText(series.name, AXIS_SIZE+2, g.font.size+2)
		
		val panelWidth = width - AXIS_SIZE - AXIS_OFFSET
		val panelHeight = height - AXIS_OFFSET
		
		val widthCandleRendered = WIDTH_TICK * scaleX
		val startCandle = Math.floor(x / widthCandleRendered) as int
		val endCandle = Math.min(series.tickCount-1, startCandle + Math.floor(panelWidth / widthCandleRendered) as int)
		val candles = (startCandle .. endCandle).map[series.getTick(it)].toList()
		val minPrice = candles.min[a, b|a.minPrice.compareTo(b.minPrice)].minPrice.toDouble
		val maxPrice = candles.max[a, b|a.maxPrice.compareTo(b.maxPrice)].maxPrice.toDouble
		
		val axis = NumberAxis.fromRange(minPrice, maxPrice, panelHeight)
		val map = [
			val valueToAxis = map(it, minPrice, maxPrice, axis.minValue, axis.maxValue)
			val valueOnChart = map(valueToAxis, axis.minValue, axis.maxValue, 0, -panelHeight)
			valueOnChart
		]
		
		g.save()
		g.translate(AXIS_SIZE+(AXIS_OFFSET/2), height-(AXIS_OFFSET/2))
		g.scale(scaleX, 1)

		candles.forEach [
			val yWick = map.apply(it.maxPrice.toDouble)
			val lengthWick = map.apply(it.minPrice.toDouble) - yWick

			val upper = it.openPrice.max(it.closePrice).toDouble
			val lower = it.openPrice.min(it.closePrice).toDouble
			val yBody = map.apply(upper)
			val lengthBody = map.apply(lower) - yBody
			
			drawCandlestick(g, bullish, yWick, lengthWick, yBody, lengthBody)
			
			g.translate(WIDTH_TICK, 0)
		]
		g.restore()
		
		drawYAxis(g, height, minPrice, maxPrice)
	}

	def drawCandlestick(GraphicsContext g, boolean bullish, double yWick, double lengthWick, double yBody, double lengthBody) {
		g.fill = Color.WHITE
		g.fillRect(0, yWick, WIDTH_WICK, lengthWick)
		g.fill = if(bullish) Color.GREEN else Color.RED
		g.fillRect(-Math.floor(WIDTH_CANDLESTICK / 2), yBody, WIDTH_CANDLESTICK, lengthBody)
	}
	
	def drawLineIndicator(Indicator<?> indicator, GraphicsContext g, double width, double height, int x, double scaleX) {
		val panelWidth = width - AXIS_SIZE - AXIS_OFFSET
		val panelHeight = height - AXIS_OFFSET
		
		val widthCandleRendered = WIDTH_TICK * scaleX
		val startCandle = Math.floor(x / widthCandleRendered) as int
		val endCandle = Math.min(indicator.timeSeries.tickCount-1, startCandle + Math.floor(panelWidth / widthCandleRendered) as int)
		val candles = (startCandle .. endCandle).map[(indicator.getValue(it) as Decimal).toDouble].toList()
		val minPrice = candles.min[a, b|a.compareTo(b)]
		val maxPrice = candles.max[a, b|a.compareTo(b)]
		
		val axis = NumberAxis.fromRange(minPrice, maxPrice, height)
		val map = [
			val valueToAxis = map(it, minPrice, maxPrice, axis.minValue, axis.maxValue)
			val valueOnChart = map(valueToAxis, axis.minValue, axis.maxValue, 0, -panelHeight)
			valueOnChart
		]
		
		g.save()
		g.translate(AXIS_SIZE+(AXIS_OFFSET/2), height-(AXIS_OFFSET/2))
		g.scale(scaleX, 1)

		candles.forEach[tick,index|
			if(index != 0) {
				val previous = candles.get(index-1)
				
				val startHeight = map.apply(previous)
				val endHeight = map.apply(tick)
				
        		g.setStroke(Color.CYAN)
        		g.setLineWidth(1)
        		g.strokeLine(0, startHeight, WIDTH_TICK, endHeight)
				g.translate(WIDTH_TICK, 0)
			}
		]
		g.restore()
		
		drawYAxis(g, height, minPrice, maxPrice)
		drawIndicatorName(indicator, g)
	}
	
	def drawIndicatorName(Indicator<?> indicator, GraphicsContext g) {
		g.fillText(indicator.toString(), AXIS_SIZE+2, g.font.size+2)
	}
	
	def drawYAxis(GraphicsContext g, double height, double minPrice, double maxPrice) {
		g.fill = Color.WHITE
		g.fillRect(AXIS_SIZE-1, 0, 1, height)
		
		val axisLength = height - AXIS_OFFSET
		
		val axis = NumberAxis.fromRange(minPrice, maxPrice, axisLength)
		axis.ticks.forEach[tick, index|
			val text = new Text(tick)
			g.fillText(tick, 0, axisLength - (axisLength/axis.ticks.size * index)+text.layoutBounds.height/2, AXIS_SIZE - 12)
			g.fillRect(AXIS_SIZE - 10, axisLength - (axisLength/axis.ticks.size * index), 10, 1)
		]
	}
	
	def drawXAxis(Canvas canvas, GraphicsContext g, List<Tick> candles) {
		g.fill = Color.WHITE
		g.fillRect(AXIS_SIZE, canvas.height-AXIS_SIZE-1, canvas.width, 1)
	}

	def map(double x, double in_min, double in_max, double out_min, double out_max) {
		return out_min + ((out_max - out_min) / (in_max - in_min)) * (x - in_min)
	}
	
	override getTickSize() {
		return WIDTH_TICK
	}
	
}
