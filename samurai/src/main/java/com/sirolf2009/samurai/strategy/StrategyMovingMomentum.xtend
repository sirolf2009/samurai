package com.sirolf2009.samurai.strategy

import com.sirolf2009.samurai.annotations.Register
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
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Optional

@Register(name="Moving momentum", type="Built-In")
class StrategyMovingMomentum implements IStrategy {
	
	// we keep these indicators as variables, so we can re-use them when we're asked what indicators we'd like to show
	// Note that the type MUST be Indicator<Decimal>
	var Indicator<Decimal> shortEma
	var Indicator<Decimal> longEma
	var Indicator<Decimal> stochasticOscillK
	var Indicator<Decimal> macd
	var Indicator<Decimal> emaMacd
	
	// we have six parameters for this strategy. These annotations will ensure that the user can change them in the GUI
	@Accessors @Param var int shortPeriod = 9
	@Accessors @Param var int longPeriod = 26
	@Accessors @Param var int stochPeriod = 14
	@Accessors @Param var int macdShortPeriod = 9
	@Accessors @Param var int macdLongPeriod = 26
	@Accessors @Param var int macdSmooth = 18
	
	// if this confuses you, you should read the TA4J documentation. Not mine	
	override setupLongingStrategy(TimeSeries series) {
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
        
        return Optional.of(new Strategy(entryRule, exitRule))
	}
	
	// Here we set up our indicators
	override indicators(TimeSeries series) {
        return #[
        	0 -> #[shortEma, longEma], //Our ema's should appear in the price panel, so we give them a key of 0
        	1 -> #[stochasticOscillK], //Our stoch should have it's own panel, we give it a key of 1 and don't add any other indicators
        	2 -> #[macd, emaMacd] //Our MACD and MACD EMA should both be in the same panel, we give them a key of 2
        ]
	}
	
}