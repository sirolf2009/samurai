package com.sirolf2009.samurai.criterion

import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.Trade
import eu.verdelhan.ta4j.TradesRecord
import eu.verdelhan.ta4j.analysis.criteria.AbstractAnalysisCriterion

class AbsoluteProfitCriterion extends AbstractAnalysisCriterion {
	
	override calculate(TimeSeries series, TradesRecord tradingRecord) {
		if(tradingRecord.tradeCount == 0) {
			return 0
		}
        return tradingRecord.map[calculateProfit(series, it)].reduce[a,b|a+b]
	}
	
	override calculate(TimeSeries series, Trade trade) {
        return calculateProfit(series, trade)
	}
	
	override betterThan(double criterionValue1, double criterionValue2) {
        return criterionValue1 > criterionValue2
	}
	
    def double calculateProfit(TimeSeries series, Trade trade) {
        if (trade.closed) {
            val exitClosePrice = series.getTick(trade.getExit().getIndex()).getClosePrice()
            val entryClosePrice = series.getTick(trade.getEntry().getIndex()).getClosePrice()
            
            if (trade.entry.isBuy()) {
                return exitClosePrice.minus(entryClosePrice).toDouble()
            } else {
                return entryClosePrice.minus(exitClosePrice).toDouble()
            }
        }
        return 0
    }
	
}
