package com.sirolf2009.samurai.strategy

import com.sirolf2009.samurai.annotations.Register
import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.Strategy
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.indicators.simple.ClosePriceIndicator
import eu.verdelhan.ta4j.indicators.trackers.SMAIndicator
import eu.verdelhan.ta4j.trading.rules.CrossedDownIndicatorRule
import eu.verdelhan.ta4j.trading.rules.CrossedUpIndicatorRule
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Optional

@Register(name="SMA crossover", type="Built-In")
class StrategySMACrossover implements IStrategy {
	
	// we keep these two indicators as variables, so we can re-use them when we're asked what indicators we'd like to show
	// Note that the type MUST be Indicator<Decimal>
	var Indicator<Decimal> shortSma
	var Indicator<Decimal> longSma
	
	// we have two parameters for this strategy. These annotations will ensure that the user can change them in the GUI
	@Param @Accessors var int shortPeriod = 5
	@Param @Accessors var int longPeriod = 30

	// if this confuses you, you should read the TA4J documentation. Not mine	
	override setupLongingStrategy(TimeSeries series) {
		val closePrice = new ClosePriceIndicator(series)

        shortSma = new SMAIndicator(closePrice, shortPeriod)
        longSma = new SMAIndicator(closePrice, longPeriod)

        val buyingRule = new CrossedUpIndicatorRule(shortSma, longSma)
        val sellingRule = new CrossedDownIndicatorRule(shortSma, longSma)
        
        return Optional.of(new Strategy(buyingRule, sellingRule))
	}
	
	override setupShortingStrategy(TimeSeries series) {
		val closePrice = new ClosePriceIndicator(series)

        shortSma = new SMAIndicator(closePrice, shortPeriod)
        longSma = new SMAIndicator(closePrice, longPeriod)

        val shortingRule = new CrossedDownIndicatorRule(shortSma, longSma)
        val coveringRule = new CrossedUpIndicatorRule(shortSma, longSma)
        
        return Optional.of(new Strategy(shortingRule, coveringRule))
	}
	
	// We want to add both our indicators to the 0th panel, which is the price panel
	override indicators(TimeSeries series) {
        return #[
        	0 -> #[shortSma, longSma]
        ]
	}
	
}