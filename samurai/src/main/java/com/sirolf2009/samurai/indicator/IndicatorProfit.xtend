package com.sirolf2009.samurai.indicator

import com.sirolf2009.samurai.criterion.AbsoluteProfitCriterion
import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.TradingRecord
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors class IndicatorProfit implements Indicator<Decimal> {
	
	val TimeSeries timeSeries

    val List<Decimal> values

	new(TimeSeries timeSeries, TradingRecord record) {
		this.timeSeries = timeSeries
		values = new ArrayList<Decimal>(timeSeries.tickCount)
		var profit = Decimal.ZERO
		val profitCalc = new AbsoluteProfitCriterion()
		for(var i = 0; i < timeSeries.tickCount; i++) {
			val index = i
			val trade = record.trades.findFirst[exit.index == index]
			if(trade !== null) {
				profit = profit.plus(Decimal.valueOf(profitCalc.calculate(timeSeries, trade)))
			}
			values.add(index, profit)
		}
	}
				
	override getValue(int index) {
		return values.get(index)
	}
	
	override toString() {
		"Profit in $"
	}
	
}
