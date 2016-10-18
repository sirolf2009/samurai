package com.sirolf2009.samurai.renderer

import com.sirolf2009.samurai.criterion.AbsoluteProfitCriterion
import com.sirolf2009.samurai.criterion.BiggestPendingLossCriterion
import com.sirolf2009.samurai.criterion.BiggestPendingProfitCriterion
import com.sirolf2009.samurai.renderer.chart.ChartData
import com.sirolf2009.samurai.renderer.chart.DateAxis
import com.sirolf2009.samurai.renderer.chart.Marker
import com.sirolf2009.samurai.renderer.chart.NumberAxis
import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.Tick
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.TradingRecord
import java.util.ArrayList
import java.util.List
import javafx.geometry.VPos
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext
import javafx.scene.paint.Color
import javafx.scene.text.Text
import javafx.scene.text.TextAlignment

import static extension com.sirolf2009.samurai.renderer.chart.ChartData.*

class RendererDefault implements IRenderer {

	public static val WIDTH_CANDLESTICK = 9
	public static val WIDTH_WICK = 1
	public static val SPACING = 2
	public static val WIDTH_TICK = WIDTH_CANDLESTICK + SPACING
	public static val Y_AXIS_SIZE = 48
	public static val X_AXIS_SIZE = 24
	public static val AXIS_OFFSET = 16

	override drawChart(ChartData chart, Canvas canvas, GraphicsContext g, int x, double scaleX) {
		val panels = 2 + chart.indicators.map[key].max // price chart counts as 2, because it should be twice as big
		val heightPerPanel = (canvas.height - X_AXIS_SIZE - AXIS_OFFSET) / panels

		val panelWidth = canvas.width - Y_AXIS_SIZE - AXIS_OFFSET
		val widthCandleRendered = WIDTH_TICK * scaleX
		val startCandle = Math.max(0, Math.floor(x / widthCandleRendered)) as int
		val endCandle = Math.max(0, Math.min(chart.timeseries.tickCount - 1, startCandle + Math.floor(panelWidth / widthCandleRendered) as int))
		{
			val panelHeight = heightPerPanel * 2 - AXIS_OFFSET
			val minPrice = Math.min(chart.min(startCandle, endCandle), chart.min(0, startCandle, endCandle))
			val maxPrice = Math.max(chart.max(startCandle, endCandle), chart.max(0, startCandle, endCandle))
			val axis = NumberAxis.fromRange(minPrice, maxPrice, panelHeight)

			drawTimeseries(axis, chart.timeseries, chart.markers.filter[key == 0].map[value].toList(), g, canvas.width, heightPerPanel * 2, x, scaleX, startCandle, endCandle)
			chart.indicatorsInPanel(0).forEach [
				drawLineIndicator(axis, it, new ArrayList(), g, canvas.width, heightPerPanel * 2, x, scaleX, startCandle, endCandle)
			]
			drawTrades(axis, chart.timeseries, chart.tradingrecord, g, canvas.width, heightPerPanel*2, x, scaleX, startCandle, endCandle)
			g.translate(0, heightPerPanel * 2)
		}
		if(panels > 2) {
			(1 .. panels - 2).forEach [ panel |
				g.stroke = Color.WHITE
				g.lineWidth = 2
				g.strokeLine(0, 0, canvas.width, 0)

				val panelHeight = heightPerPanel - AXIS_OFFSET
				val minPrice = chart.indicatorsInPanel(panel).min(startCandle, endCandle)
				val maxPrice = chart.indicatorsInPanel(panel).max(startCandle, endCandle)
				val axis = NumberAxis.fromRange(minPrice, maxPrice, panelHeight)
				chart.indicatorsInPanel(panel).forEach [
					drawLineIndicator(axis, it, new ArrayList(), g, canvas.width, heightPerPanel, x, scaleX, startCandle, endCandle)
				]
				g.translate(0, heightPerPanel)
			]
		}
		val candles = (startCandle .. endCandle).map[chart.timeseries.getTick(it)].toList()
		drawXAxis(canvas.width, g, candles)
	}

	def drawTimeseries(NumberAxis axis, TimeSeries series, List<Marker> markers, GraphicsContext g, double width, double height, int x, double scaleX) {
		val panelWidth = width - Y_AXIS_SIZE - AXIS_OFFSET

		val widthCandleRendered = WIDTH_TICK * scaleX
		val startCandle = Math.max(0, Math.floor(x / widthCandleRendered)) as int
		val endCandle = Math.max(0, Math.min(series.tickCount - 1, startCandle + Math.floor(panelWidth / widthCandleRendered) as int))

		drawTimeseries(axis, series, markers, g, width, height, x, scaleX, startCandle, endCandle)
	}

	def drawTimeseries(NumberAxis axis, TimeSeries series, List<Marker> markers, GraphicsContext g, double width, double height, int x, double scaleX, int startCandle, int endCandle) {
		g.setLineWidth(1)
		g.fill = Color.WHITE
		g.fillText(series.name, Y_AXIS_SIZE + 2, g.font.size + 2)

		val candles = (startCandle .. endCandle).map[series.getTick(it)].toList()

		g.save()
		g.translate(Y_AXIS_SIZE + (AXIS_OFFSET / 2), height - (AXIS_OFFSET / 2))
		g.scale(scaleX, 1)

		candles.forEach [ it, index |
			val yWick = axis.map(it.maxPrice.toDouble)
			val lengthWick = axis.map(it.minPrice.toDouble) - yWick

			val upper = it.openPrice.max(it.closePrice).toDouble
			val lower = it.openPrice.min(it.closePrice).toDouble
			val yBody = axis.map(upper)
			val lengthBody = axis.map(lower) - yBody

			drawCandlestick(g, bullish, yWick, lengthWick, yBody, lengthBody)
			markers.filter[it.x == startCandle + index].forEach [ marker |
				g.save()
				g.translate(0, axis.map(closePrice.toDouble))
				marker.renderable.render(g, it)
				g.restore()
			]

			g.translate(WIDTH_TICK, 0)
		]
		g.restore()

		drawYAxis(g, height, axis.minValue, axis.maxValue)
	}

	def drawCandlestick(GraphicsContext g, boolean bullish, double yWick, double lengthWick, double yBody, double lengthBody) {
		g.save()
		g.fill = Color.WHITE
		g.fillRect(0, yWick, WIDTH_WICK, lengthWick)
		g.fill = if(bullish) Color.RED else Color.GREEN
		g.fillRect(-Math.floor(WIDTH_CANDLESTICK / 2), yBody, WIDTH_CANDLESTICK, lengthBody)
		g.restore()
	}

	def drawTrades(NumberAxis axis, TimeSeries series, TradingRecord record, GraphicsContext g, double width, double height, int x, double scaleX, int startCandle, int endCandle) {
		val candles = (startCandle .. endCandle).map[series.getTick(it)].toList()

		g.save()
		g.translate(Y_AXIS_SIZE + (AXIS_OFFSET / 2), height - (AXIS_OFFSET / 2))
		g.scale(scaleX, 1)
		
		val profitCrit = new AbsoluteProfitCriterion() 
		val pendingLossCrit = new BiggestPendingLossCriterion()
		val pendingProfitCrit = new BiggestPendingProfitCriterion()

		candles.forEach [ it, index |
			record.trades.filter[entry.index == startCandle + index].forEach [
				g.save()
				val pixelsLeft = width - (index*WIDTH_TICK)
				val tradeWidth = Math.min((exit.index-entry.index)*WIDTH_TICK, pixelsLeft)
				val entryOnChart = axis.map(entry.price.toDouble())
				val exitOnChart = axis.map(exit.price.toDouble)
				val profit = profitCrit.calculate(series, it)
				val pendingLoss = pendingLossCrit.calculate(series, it)
				val pendingProfit = pendingProfitCrit.calculate(series, it)
				g.fill = new Color(1, 0, 0, 0.25)
				g.fillRect(0, entryOnChart, tradeWidth, Math.abs(axis.map(entry.price.toDouble())-axis.map(entry.price.toDouble()-pendingLoss)))
				g.fill = new Color(0, 1, 0, 0.25)
				g.fillRect(0, axis.map(entry.price.toDouble()+pendingProfit), tradeWidth, axis.map(entry.price.toDouble())-axis.map(entry.price.toDouble()+pendingProfit))
				g.fill = if(profit > 0) new Color(0, 1, 0, 0.5) else new Color(1, 0, 0, 0.5)
				g.fillRect(0, Math.min(entryOnChart, exitOnChart), tradeWidth, Math.abs(exitOnChart-entryOnChart))
				g.restore()
			]

			g.translate(WIDTH_TICK, 0)
		]
		g.restore()
	}

	def drawLineIndicatorChart(Indicator<Decimal> indicator, List<Marker> markers, GraphicsContext g, double width, double height, int x, double scaleX) {
		val panelWidth = width - Y_AXIS_SIZE - AXIS_OFFSET
		val widthCandleRendered = WIDTH_TICK * scaleX
		val startCandle = Math.max(0, Math.floor(x / widthCandleRendered)) as int
		val endCandle = Math.max(0, Math.min(indicator.timeSeries.tickCount - 1, startCandle + Math.floor(panelWidth / widthCandleRendered) as int))

		val minPrice = indicator.min(startCandle, endCandle)
		val maxPrice = indicator.max(startCandle, endCandle)
		val axis = NumberAxis.fromRange(minPrice, maxPrice, height - X_AXIS_SIZE - AXIS_OFFSET)

		drawLineIndicator(axis, indicator, markers, g, panelWidth, height - X_AXIS_SIZE - AXIS_OFFSET, x, scaleX)
		g.translate(0, height - X_AXIS_SIZE - AXIS_OFFSET)

		val candles = (startCandle .. endCandle).map[indicator.timeSeries.getTick(it)].toList()
		drawXAxis(width, g, candles)
	}

	def drawLineIndicator(NumberAxis axis, Indicator<?> indicator, List<Marker> markers, GraphicsContext g, double width, double height, int x, double scaleX) {
		val panelWidth = width - Y_AXIS_SIZE - AXIS_OFFSET
		val widthCandleRendered = WIDTH_TICK * scaleX
		val startCandle = Math.max(0, Math.floor(x / widthCandleRendered)) as int
		val endCandle = Math.max(0, Math.min(indicator.timeSeries.tickCount - 1, startCandle + Math.floor(panelWidth / widthCandleRendered) as int))

		drawLineIndicator(axis, indicator, markers, g, width, height, x, scaleX, startCandle, endCandle)
	}

	def drawLineIndicator(NumberAxis axis, Indicator<?> indicator, List<Marker> markers, GraphicsContext g, double width, double height, int x, double scaleX, int startCandle, int endCandle) {
		val candles = (startCandle .. endCandle).map[(indicator.getValue(it) as Decimal).toDouble].toList()

		g.save()
		g.translate(Y_AXIS_SIZE + (AXIS_OFFSET / 2), height - (AXIS_OFFSET / 2))
		g.scale(scaleX, 1)

		candles.forEach [ tick, index |
			if(index != 0) {
				val previous = candles.get(index - 1)

				val startHeight = axis.map(previous)
				val endHeight = axis.map(tick)

				g.setStroke(Color.CYAN)
				g.setLineWidth(1)
				g.strokeLine(0, startHeight, WIDTH_TICK, endHeight)
				markers.filter[it.x == startCandle + index].forEach [ marker |
					g.save()
					marker.renderable.render(g, indicator.timeSeries.getTick(startCandle + index))
					g.restore()
				]
				g.translate(WIDTH_TICK, 0)
			}
		]
		g.restore()

		drawYAxis(g, height, axis.minValue, axis.maxValue)
		drawIndicatorName(indicator, g)
	}

	def drawIndicatorName(Indicator<?> indicator, GraphicsContext g) {
		g.fillText(indicator.toString(), Y_AXIS_SIZE + 2, g.font.size + 2)
	}

	def drawYAxis(GraphicsContext g, double height, double minPrice, double maxPrice) {
		g.fill = Color.WHITE
		g.fillRect(Y_AXIS_SIZE - 1, 0, 1, height)

		val axisLength = height - AXIS_OFFSET

		val axis = NumberAxis.fromRange(minPrice, maxPrice, axisLength)
		axis.ticks.forEach [ tick, index |
			val text = new Text(tick)
			g.fillText(tick, 0, axisLength - (axisLength / axis.ticks.size * index) + text.layoutBounds.height / 2, Y_AXIS_SIZE - 12)
			g.fillRect(Y_AXIS_SIZE - 10, axisLength - (axisLength / axis.ticks.size * index), 10, 1)
		]
	}

	def drawXAxis(double width, GraphicsContext g, List<Tick> candles) {
		g.fill = Color.WHITE
		g.fillRect(Y_AXIS_SIZE, -1, width - Y_AXIS_SIZE, 1)

		val from = candles.get(0).endTime
		val to = candles.last.endTime
		val axisWidth = width - Y_AXIS_SIZE - AXIS_OFFSET
		val axis = DateAxis.fromRange(from, to, width - AXIS_OFFSET)
		val size = g.font.size
		g.textAlign = TextAlignment.CENTER
		g.textBaseline = VPos.CENTER
		axis.ticks.forEach [ tick, index |
			val x = (axisWidth / axis.ticks.size * index) + (Y_AXIS_SIZE + AXIS_OFFSET)
			g.fillText(tick, x, size + 12)
			g.fillRect(x, 0, 1, 10)
		]
	}

	def map(double x, double in_min, double in_max, double out_min, double out_max) {
		return out_min + ((out_max - out_min) / (in_max - in_min)) * (x - in_min)
	}

	override getTickSize() {
		return WIDTH_TICK
	}

}
