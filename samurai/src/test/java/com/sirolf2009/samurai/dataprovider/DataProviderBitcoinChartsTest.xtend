package com.sirolf2009.samurai.dataprovider

import com.sirolf2009.samurai.JavaFXThreadingRule
import com.sirolf2009.samurai.Resources
import java.time.Duration
import java.time.Instant
import java.time.ZoneId
import java.time.ZonedDateTime
import junit.framework.Assert
import org.junit.Rule
import org.junit.Test

class DataProviderBitcoinChartsTest {
	
	@Rule public val javafxRule = new JavaFXThreadingRule()
	val resources = new Resources(DataProviderBitcoinChartsTest)
	val zone = ZoneId.of("Europe/Amsterdam")
	
	@Test
	def void test() {
		val provider = new DataProviderBitcoinCharts(resources.getFile("bitfinexUSD.csv"))
		provider.period = Duration.ofMinutes(1)
		provider.from = ZonedDateTime.ofInstant(Instant.ofEpochSecond(1364767668), zone)
		provider.to = ZonedDateTime.ofInstant(Instant.ofEpochSecond(1364774898), zone)
		val series = provider.call()
		Assert.assertEquals(21, series.tickCount)
	}
	
}