package com.sirolf2009.samurai.strategy

import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.Strategy
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.indicators.oscillators.StochasticOscillatorKIndicator
import eu.verdelhan.ta4j.indicators.simple.ClosePriceIndicator
import eu.verdelhan.ta4j.indicators.trackers.EMAIndicator
import eu.verdelhan.ta4j.indicators.trackers.MACDIndicator
import eu.verdelhan.ta4j.trading.rules.CrossedDownIndicatorRule
import eu.verdelhan.ta4j.trading.rules.CrossedUpIndicatorRule
import eu.verdelhan.ta4j.trading.rules.OverIndicatorRule
import eu.verdelhan.ta4j.trading.rules.UnderIndicatorRule

class StrategyMovingMomentum implements IStrategy {
	
	var Indicator<Decimal> shortEma
	var Indicator<Decimal> longEma
	var Indicator<Decimal> stochasticOscillK
	var Indicator<Decimal> macd
	var Indicator<Decimal> emaMacd
	
	@Param public var shortPeriod = 9
	@Param public var longPeriod = 26
	@Param public var stochPeriod = 14
	@Param public var macdShortPeriod = 9
	@Param public var macdLongPeriod = 26
	@Param public var macdSmooth = 18
	
	override setup(TimeSeries series) {
        val closePrice = new ClosePriceIndicator(series)
        
        shortEma = new EMAIndicator(closePrice, shortPeriod)
        longEma = new EMAIndicator(closePrice, longPeriod)

        stochasticOscillK = new StochasticOscillatorKIndicator(series, stochPeriod)

        macd = new MACDIndicator(closePrice, macdShortPeriod, macdLongPeriod)
        emaMacd = new EMAIndicator(macd, macdSmooth)
        
        val entryRule = new OverIndicatorRule(shortEma, longEma)
                .and(new CrossedDownIndicatorRule(stochasticOscillK, Decimal.valueOf(20)))
                .and(new OverIndicatorRule(macd, emaMacd))
        
        val exitRule = new UnderIndicatorRule(shortEma, longEma)
                .and(new CrossedUpIndicatorRule(stochasticOscillK, Decimal.valueOf(80)))
                .and(new UnderIndicatorRule(macd, emaMacd))
        
        return new Strategy(entryRule, exitRule)
	}
	
	override indicators(TimeSeries series) {
        return #[
        	0 -> #[shortEma, longEma],
        	1 -> #[stochasticOscillK],
        	2 -> #[macd, emaMacd]
        ]
	}
	
}