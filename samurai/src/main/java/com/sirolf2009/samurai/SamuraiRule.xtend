package com.sirolf2009.samurai

import eu.verdelhan.ta4j.trading.rules.AbstractRule
import eu.verdelhan.ta4j.TradingRecord
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.Decimal

abstract class SamuraiRule extends AbstractRule {
	
	val TimeSeries series
	var int index
	
	new(TimeSeries series) {
		this.series = series;
	}

	override isSatisfied(int index, TradingRecord tradingRecord) {
		this.index = index
		return isSatisfied()
	}
	
	def boolean isSatisfied()
	
	def Decimal open(int barsAgo) {
		return series.getTick(index-barsAgo).openPrice
	}
	
	def Decimal high(int barsAgo) {
		return series.getTick(index-barsAgo).maxPrice
	}
	
	def Decimal low(int barsAgo) {
		return series.getTick(index-barsAgo).minPrice
	}
	
	def Decimal close(int barsAgo) {
		return series.getTick(index-barsAgo).closePrice
	}
	
}