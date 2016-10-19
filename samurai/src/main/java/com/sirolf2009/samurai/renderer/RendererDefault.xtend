package com.sirolf2009.samurai.renderer

import com.sirolf2009.samurai.criterion.AbsoluteProfitCriterion
import com.sirolf2009.samurai.criterion.BiggestPendingLossCriterion
import com.sirolf2009.samurai.criterion.BiggestPendingProfitCriterion
import com.sirolf2009.samurai.renderer.chart.DateAxis
import com.sirolf2009.samurai.renderer.chart.Marker
import com.sirolf2009.samurai.renderer.chart.NumberAxis
import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.TradingRecord
import java.util.List
import javafx.geometry.VPos
import javafx.scene.canvas.GraphicsContext
import javafx.scene.paint.Color
import javafx.scene.text.Text
import javafx.scene.text.TextAlignment

import static com.sirolf2009.samurai.renderer.chart.ChartSettings.*

class RendererDefault implements IRenderer {

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

		axis.drawYAxis(g)
	}

	def drawCandlestick(GraphicsContext g, boolean bullish, double yWick, double lengthWick, double yBody, double lengthBody) {
		g.save()
		g.fill = Color.WHITE
		g.fillRect(0, yWick, WIDTH_WICK, lengthWick)
		g.fill = if(bullish) Color.GREEN else Color.RED
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

		candles.forEach [ candle, index |
			record.trades.filter[entry.index == startCandle + index].forEach [
				g.save()
				val tradeWidth = (exit.index-entry.index)*(WIDTH_TICK)
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

		axis.drawYAxis(g)
		drawIndicatorName(indicator, g)
	}

	def drawIndicatorName(Indicator<?> indicator, GraphicsContext g) {
		g.fillText(indicator.toString(), Y_AXIS_SIZE + 2, g.font.size + 2)
	}

	def drawYAxis(NumberAxis axis, GraphicsContext g) {
		g.fill = Color.WHITE
		g.fillRect(Y_AXIS_SIZE - 1, 0, 1, axis.panelSize)

		axis.ticks.forEach [ tick, index |
			val text = new Text(tick)
			g.fillText(tick, 0, axis.panelSize - (axis.panelSize / axis.ticks.size * index) + text.layoutBounds.height / 2, Y_AXIS_SIZE - 12)
			g.fillRect(Y_AXIS_SIZE - 10, axis.panelSize - (axis.panelSize / axis.ticks.size * index), 10, 1)
		]
	}

	override drawXAxis(DateAxis axis, GraphicsContext g) {
		g.fill = Color.WHITE
		g.fillRect(Y_AXIS_SIZE, -1, axis.bounds.width, 1)

		val size = g.font.size
		g.textAlign = TextAlignment.CENTER
		g.textBaseline = VPos.CENTER
		axis.ticks.forEach [ tick, index |
			val x = (axis.bounds.width / axis.ticks.size * index) + Y_AXIS_SIZE + WIDTH_TICK/2
			g.fillText(tick, x, size + 12)
			g.fillRect(x, 0, 1, 10)
		]
	}

	def map(double x, double in_min, double in_max, double out_min, double out_max) {
		return out_min + ((out_max - out_min) / (in_max - in_min)) * (x - in_min)
	}

}
