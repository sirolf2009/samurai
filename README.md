![](samurai/src/main/resources/icon2.png)
# samurai

Samurai is a GUI for [TA4J](https://github.com/mdeverdelhan/ta4j). It's supposed to make it easier for you to get insights in how to improve your trading strategy.
You will be able to use all the TA4J built-in and custom indicators to create your strategies. When you have written a strategy, you run it over a dataprovider to see how it would have traded.
At some point, this will also support automated trading.

<b>Note that this is still a work in progress application and it is not yet functional enough to be used.</b>

## Strategies examples
```xtend
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
```
```xtend
class StrategyMovingMomentum implements IStrategy {
	
	// we keep these indicators as variables, so we can re-use them when we're asked what indicators we'd like to show
	// Note that the type MUST be Indicator<Decimal>
	var Indicator<Decimal> shortEma
	var Indicator<Decimal> longEma
	var Indicator<Decimal> stochasticOscillK
	var Indicator<Decimal> macd
	var Indicator<Decimal> emaMacd
	
	// we have six parameters for this strategy. The annotation will ensure that the user can change them in the GUI
	@Param public var shortPeriod = 9
	@Param public var longPeriod = 26
	@Param public var stochPeriod = 14
	@Param public var macdShortPeriod = 9
	@Param public var macdLongPeriod = 26
	@Param public var macdSmooth = 18
	
	// if this confuses you, you should read the TA4J documentation. Not mine	
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
	
	// Here we set up our indicators
	override indicators(TimeSeries series) {
        return #[
        	0 -> #[shortEma, longEma], //Our ema's should appear in the price panel, so we give them a key of 0
        	1 -> #[stochasticOscillK], //Our stoch should have it's own panel, we give it a key of 1 and don't add any other indicators
        	2 -> #[macd, emaMacd] //Our MACD and MACD EMA should both be in the same panel, we give them a key of 2
        ]
	}
	
}
```

## Screenshots

![](https://i.imgur.com/tZ2ndsL.png)
![](https://i.imgur.com/QuZZsri.png)
