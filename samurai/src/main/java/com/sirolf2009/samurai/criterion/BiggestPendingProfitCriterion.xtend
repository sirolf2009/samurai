package com.sirolf2009.samurai.criterion

import com.sirolf2009.samurai.indicator.IndicatorPendingProfit
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.Trade
import eu.verdelhan.ta4j.TradingRecord
import eu.verdelhan.ta4j.analysis.criteria.AbstractAnalysisCriterion

class BiggestPendingProfitCriterion extends AbstractAnalysisCriterion {
	
	override calculate(TimeSeries series, TradingRecord tradingRecord) {
		tradingRecord.trades.map[calculate(series, it)].max()
	}

	override calculate(TimeSeries series, Trade trade) {
		val pendingProfit = new IndicatorPendingProfit(series, trade)
		return (trade.entry.index .. trade.exit.index).map[pendingProfit.getValue(it).toDouble].max()
	}

	override betterThan(double criterionValue1, double criterionValue2) {
		return criterionValue1 < criterionValue2
	}
	
}