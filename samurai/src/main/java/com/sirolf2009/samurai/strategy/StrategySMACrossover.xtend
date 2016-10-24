package com.sirolf2009.samurai.strategy

import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.Strategy
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.indicators.simple.ClosePriceIndicator
import eu.verdelhan.ta4j.indicators.trackers.SMAIndicator
import eu.verdelhan.ta4j.trading.rules.CrossedDownIndicatorRule
import eu.verdelhan.ta4j.trading.rules.CrossedUpIndicatorRule
import com.sirolf2009.samurai.Register

@Register(name="SMA crossover")
class StrategySMACrossover implements IStrategy {
	
	// we keep these two indicators as variables, so we can re-use them when we're asked what indicators we'd like to show
	// Note that the type MUST be Indicator<Decimal>
	var Indicator<Decimal> shortSma
	var Indicator<Decimal> longSma
	
	// we have two parameters for this strategy. The annotation will ensure that the user can change them in the GUI
	@Param public var shortPeriod = 5
	@Param public var longPeriod = 30

	// if this confuses you, you should read the TA4J documentation. Not mine	
	override setup(TimeSeries series) {
		val closePrice = new ClosePriceIndicator(series)

        shortSma = new SMAIndicator(closePrice, shortPeriod)
        longSma = new SMAIndicator(closePrice, longPeriod)

        val buyingRule = new CrossedUpIndicatorRule(shortSma, longSma)
        val sellingRule = new CrossedDownIndicatorRule(shortSma, longSma)
        
        return new Strategy(buyingRule, sellingRule)
	}
	
	// We want to add both our indicators to the 0th panel, which is the price panel
	override indicators(TimeSeries series) {
        return #[
        	0 -> #[shortSma, longSma]
        ]
	}
	
}