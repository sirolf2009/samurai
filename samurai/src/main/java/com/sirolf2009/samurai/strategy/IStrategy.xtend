package com.sirolf2009.samurai.strategy

import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.Strategy
import eu.verdelhan.ta4j.TimeSeries
import java.util.List
import eu.verdelhan.ta4j.Decimal

interface IStrategy {
	
	def Strategy setup(TimeSeries series)
	def List<Pair<Integer, List<Indicator<Decimal>>>> indicators(TimeSeries series)
	
}