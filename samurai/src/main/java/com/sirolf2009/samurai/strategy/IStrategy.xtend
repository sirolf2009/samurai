package com.sirolf2009.samurai.strategy

import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.Strategy
import eu.verdelhan.ta4j.Indicator
import java.util.List

interface IStrategy {
	
	def Strategy setup(TimeSeries series)
	def List<Indicator<?>> indicators(TimeSeries series)
	
}