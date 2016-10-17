package com.sirolf2009.samurai.strategy

import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.Strategy
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.indicators.simple.ClosePriceIndicator
import eu.verdelhan.ta4j.indicators.trackers.SMAIndicator
import eu.verdelhan.ta4j.trading.rules.CrossedDownIndicatorRule
import eu.verdelhan.ta4j.trading.rules.CrossedUpIndicatorRule
import eu.verdelhan.ta4j.trading.rules.StopGainRule
import eu.verdelhan.ta4j.trading.rules.StopLossRule
import eu.verdelhan.ta4j.Indicator

class StrategySMACrossover implements IStrategy {
	
	var Indicator<Decimal> shortSma
	var Indicator<Decimal> longSma
	
	@Param public var shortPeriod = 5
	@Param public var longPeriod = 30
	
	override setup(TimeSeries series) {
		val closePrice = new ClosePriceIndicator(series)

        shortSma = new SMAIndicator(closePrice, shortPeriod)
        longSma = new SMAIndicator(closePrice, longPeriod)

        val buyingRule = new CrossedUpIndicatorRule(shortSma, longSma)
        val sellingRule = new CrossedDownIndicatorRule(shortSma, longSma)
                .or(new StopLossRule(closePrice, Decimal.valueOf("3")))
                .or(new StopGainRule(closePrice, Decimal.valueOf("2")))
        
        return new Strategy(buyingRule, sellingRule)
	}
	
	override indicators(TimeSeries series) {
        return #[
        	0 -> #[shortSma, longSma]
        ]
	}
	
}