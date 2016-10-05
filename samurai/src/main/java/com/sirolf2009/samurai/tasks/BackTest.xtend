package com.sirolf2009.samurai.tasks

import com.sirolf2009.samurai.Samurai
import com.sirolf2009.samurai.gui.TreeItemDataProvider
import com.sirolf2009.samurai.strategy.StrategySMACrossover
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.analysis.CashFlow
import eu.verdelhan.ta4j.analysis.criteria.AverageProfitableTradesCriterion
import eu.verdelhan.ta4j.analysis.criteria.RewardRiskRatioCriterion
import eu.verdelhan.ta4j.analysis.criteria.TotalProfitCriterion
import eu.verdelhan.ta4j.analysis.criteria.VersusBuyAndHoldCriterion
import javafx.beans.InvalidationListener
import javafx.beans.Observable
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.concurrent.Task
import javafx.scene.control.TreeItem
import org.joda.time.DateTime
import org.joda.time.Period
import com.sirolf2009.samurai.renderer.RendererDefault

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
				samurai.progressMessage.textProperty.bind(this.messageProperty)
				samurai.progressIndicator.progressProperty.bind(this.progressProperty)
				new Thread(this).start()
				
				new RendererDefault().drawTimeSeries(series, samurai.canvas, samurai.canvas.graphicsContext2D, 10, 0.5)
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

}
