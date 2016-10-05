package com.sirolf2009.samurai.strategy

import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.Strategy

interface IStrategy {
	
	def Strategy setup(TimeSeries series)
	
}