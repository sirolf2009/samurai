package com.sirolf2009.samurai.tasks

import com.sirolf2009.samurai.strategy.IStrategy
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.TradingRecord
import javafx.concurrent.Task
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class BackTest extends Task<TradingRecord> {

	val IStrategy strategy
	val TimeSeries series

	new(IStrategy strategy, TimeSeries series) {
		this.strategy = strategy
		this.series = series
	}

	override protected call() throws Exception {
		updateMessage("Running backtest")
		val tradingRecord = series.run(strategy.setup(series))
		updateMessage("Done")
		return tradingRecord
	}

}
