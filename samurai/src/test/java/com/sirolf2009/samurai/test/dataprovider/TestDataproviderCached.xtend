package com.sirolf2009.samurai.test.dataprovider

import org.junit.Test
import com.sirolf2009.samurai.dataprovider.DataProviderCachedBitcoinCharts
import org.joda.time.DateTime
import org.joda.time.Period
import eu.verdelhan.ta4j.TimeSeries

class TestDataproviderCached {
	
	@Test
	def void test() {
		val provider = new DataProviderCachedBitcoinCharts("data/bitstampUSD.csv")
		provider.from = new DateTime(0)
		provider.to = new DateTime(System.currentTimeMillis)
		provider.onSucceeded = [
			println(it.source.value as TimeSeries)
		]
		provider.exceptionProperty.addListener[
			println(it)
		]
		
		val periodMinute = new Period(1000*60)
		provider.period = periodMinute
		new Thread(provider).start()
		Thread.sleep(1000)
	}
	
}