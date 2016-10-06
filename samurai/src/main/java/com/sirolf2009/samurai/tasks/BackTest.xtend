package com.sirolf2009.samurai.tasks

import com.sirolf2009.samurai.Samurai
import com.sirolf2009.samurai.gui.TreeItemDataProvider
import com.sirolf2009.samurai.renderer.RendererDefault
import com.sirolf2009.samurai.renderer.chart.Chart
import com.sirolf2009.samurai.strategy.StrategySMACrossover
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.analysis.CashFlow
import eu.verdelhan.ta4j.analysis.criteria.AverageProfitableTradesCriterion
import eu.verdelhan.ta4j.analysis.criteria.RewardRiskRatioCriterion
import eu.verdelhan.ta4j.analysis.criteria.TotalProfitCriterion
import eu.verdelhan.ta4j.analysis.criteria.VersusBuyAndHoldCriterion
import eu.verdelhan.ta4j.indicators.simple.ClosePriceIndicator
import eu.verdelhan.ta4j.indicators.trackers.SMAIndicator
import javafx.beans.InvalidationListener
import javafx.beans.Observable
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.concurrent.Task
import javafx.scene.control.TreeItem
import javafx.scene.paint.Color
import org.joda.time.DateTime
import org.joda.time.Period

class BackTest extends Task<Void> implements InvalidationListener {

	val Samurai samurai
	var TimeSeries series

	new(Samurai samurai) {
		this.samurai = samurai
	}

	override invalidated(Observable observable) {
		val node = (observable as ReadOnlyObjectProperty<TreeItem<String>>).value
		if(node instanceof TreeItemDataProvider) {
			val provider = (node as TreeItemDataProvider).provider
			provider => [
				period = new Period(1000 * 60 * 60)
				from = new DateTime(0)
				to = new DateTime(System.currentTimeMillis)
				samurai.progressMessage.textProperty.bind(messageProperty)
				samurai.progressIndicator.progressProperty.bind(progressProperty)
			]
			new Thread(provider).start()

			provider.onSucceeded = [
				series = it.source.value as TimeSeries
				draw()
			]
		}
	}

	override protected call() throws Exception {
		updateMessage("Running backtest")
		val strat = new StrategySMACrossover()
		val tradingRecord = series.run(strat.setup(series))

		updateMessage("Parsing results")
		val cashFlow = new CashFlow(series, tradingRecord)
		println("Net Profit: " + cashFlow.getValue(cashFlow.size - 1))

		val profitTradesRatio = new AverageProfitableTradesCriterion()
		System.out.println("Profitable trades ratio: " + profitTradesRatio.calculate(series, tradingRecord))

		val rewardRiskRatio = new RewardRiskRatioCriterion()
		System.out.println("Reward-risk ratio: " + rewardRiskRatio.calculate(series, tradingRecord))

		val vsBuyAndHold = new VersusBuyAndHoldCriterion(new TotalProfitCriterion())
		System.out.println("Our profit vs buy-and-hold profit: " + vsBuyAndHold.calculate(series, tradingRecord))

		return null
	}

	def draw() {
		if(series != null) {

			samurai.progressMessage.textProperty.bind(this.messageProperty)
			samurai.progressIndicator.progressProperty.bind(this.progressProperty)
			new Thread(this).start()

			val sma = new SMAIndicator(new ClosePriceIndicator(series), 8)
			val chart = new Chart(series, #[sma])

			val g = samurai.canvas.graphicsContext2D
			g.save()
			g.fill = Color.BLACK.brighter
			g.fillRect(0, 0, samurai.canvas.width, samurai.canvas.height)

			new RendererDefault().drawChart(chart, samurai.canvas, g, 0, 0.5)

			g.restore()
		}
	}

}
