package com.sirolf2009.samurai.dataprovider

import org.joda.time.DateTime
import org.joda.time.Period

class DataProviderCachedBitcoinCharts extends DataProviderCached {
	
	static val NAME = "BitcoinCharts-"
	
	val DataProviderBitcoinCharts provider
	
	new(String file) {
		super(NAME+file)
		provider = new DataProviderBitcoinCharts(file)
	}
	
	override loadExternal(Period period, DateTime from, DateTime to) {
		provider.period = period
		provider.from = from
		provider.to = to
		provider.call
	}
	
}