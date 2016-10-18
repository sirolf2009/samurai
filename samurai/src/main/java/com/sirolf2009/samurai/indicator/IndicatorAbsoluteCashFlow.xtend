package com.sirolf2009.samurai.indicator

import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.Trade
import eu.verdelhan.ta4j.TradingRecord
import java.util.ArrayList
import java.util.Arrays
import java.util.Collections
import org.eclipse.xtend.lib.annotations.Accessors

class IndicatorAbsoluteCashFlow implements Indicator<Decimal> {
	
	@Accessors val TimeSeries timeSeries
    val values = new ArrayList(Arrays.asList(Decimal.ZERO))
	
	new(TimeSeries timeSeries, Trade trade) {
		this.timeSeries = timeSeries
		calculate(trade)
		fillToTheEnd()
	}
	
	new(TimeSeries timeSeries, TradingRecord tradingRecord) {
		this.timeSeries = timeSeries
		tradingRecord.trades.forEach[calculate(it)]
		fillToTheEnd()
	}
	
	override getValue(int index) {
		return values.get(index)
	}
	
	def calculate(Trade trade) {
		val entryIndex = trade.entry.index
        val begin = entryIndex + 1
        if(begin > values.size()) {
            val lastValue = values.last
            values += Collections.nCopies(begin - values.size(), lastValue)
        }
        val end = trade.exit.index
        for (var i = Math.max(begin, 1); i <= end; i++) {
            val change = if (trade.getEntry().isBuy()) {
                timeSeries.getTick(i).closePrice.minus(timeSeries.getTick(entryIndex).closePrice)
            } else {
                timeSeries.getTick(entryIndex).closePrice.minus(timeSeries.getTick(i).closePrice)
            }
            values.add(change)
        }
	}
	
    def fillToTheEnd() {
        if (timeSeries.end >= values.size()) {
            val lastValue = values.last
            values += Collections.nCopies(timeSeries.getEnd() - values.size() + 1, lastValue)
        }
    }
	
	override toString() {
		return "Cash Flow in $"
	}
	
}
