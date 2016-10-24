package com.sirolf2009.samurai.renderer.chart

import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.Indicator
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.TradingRecord
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class ChartData {
	
	TimeSeries timeseries
	TradingRecord tradingrecord
	List<Pair<Integer, List<Indicator<Decimal>>>> indicators
	List<Pair<Integer, Marker>> markers
	
	def indicatorsInPanel(int panel) {
		indicators.filter[key == panel].map[value].flatten().toList()
	}
	
	def min(int startCandle, int endCandle) {
		(startCandle .. endCandle).map[timeseries.getTick(it)].min[a, b|a.minPrice.compareTo(b.minPrice)].minPrice.toDouble
	}
	
	def max(int startCandle, int endCandle) {
		(startCandle .. endCandle).map[timeseries.getTick(it)].max[a, b|a.maxPrice.compareTo(b.maxPrice)].maxPrice.toDouble
	}
	
	def min(int panel, int startCandle, int endCandle) {
		indicatorsInPanel(panel).min(startCandle, endCandle)
	}
	
	def static min(List<Indicator<Decimal>> indicators, int startCandle, int endCandle) {
		indicators.map[min(it, startCandle, endCandle)].min()
	}
	
	def static min(Indicator<Decimal> indicator, int startCandle, int endCandle) {
		(startCandle .. endCandle).map[index| indicator.getValue(index).toDouble()].min()
	}
	
	def max(int panel, int startCandle, int endCandle) {
		indicatorsInPanel(panel).max(startCandle, endCandle)
	}
	
	def static max(List<Indicator<Decimal>> indicators, int startCandle, int endCandle) {
		indicators.map[max(it, startCandle, endCandle)].max()
	}
	
	def static max(Indicator<Decimal> indicator, int startCandle, int endCandle) {
		(startCandle .. endCandle).map[index| indicator.getValue(index).toDouble()].max()
	}
	
}