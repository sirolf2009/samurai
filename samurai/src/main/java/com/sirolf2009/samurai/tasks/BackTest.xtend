package com.sirolf2009.samurai.tasks

import com.sirolf2009.samurai.strategy.IStrategy
import eu.verdelhan.ta4j.Order.OrderType
import eu.verdelhan.ta4j.Portfolio
import eu.verdelhan.ta4j.TimeSeries
import javafx.concurrent.Task
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class BackTest extends Task<Portfolio> {

	val IStrategy strategy
	val TimeSeries series

	new(IStrategy strategy, TimeSeries series) {
		this.strategy = strategy
		this.series = series
	}

	override protected call() throws Exception {
		updateMessage("Running backtest")
		val portfolio = new Portfolio()
		strategy.setupLongingStrategy(series).map[series.run(it, OrderType.BUY)].ifPresent[portfolio.tradingRecords.add(it)]
		strategy.setupShortingStrategy(series).map[series.run(it, OrderType.SELL)].ifPresent[portfolio.tradingRecords.add(it)]
		return portfolio
	}

}
