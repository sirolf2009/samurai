package com.sirolf2009.samurai.strategy

import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.Strategy
import eu.verdelhan.ta4j.TimeSeries
import java.util.List
import eu.verdelhan.ta4j.Decimal
import java.util.Optional

interface IStrategy {
	
	def Optional<Strategy> setupLongingStrategy(TimeSeries series) {
		return Optional.empty
	}
	def Optional<Strategy> setupShortingStrategy(TimeSeries series) {
		return Optional.empty
	}
	def List<Pair<Integer, List<Indicator<Decimal>>>> indicators(TimeSeries series)
	
}