package com.sirolf2009.samurai.test.renderer.chart

import org.junit.Test
import com.sirolf2009.samurai.renderer.chart.DateAxis
import org.joda.time.DateTime
import junit.framework.Assert

class TestDateAxis {
	
	@Test
	def void test() {
		val axis = DateAxis.fromRange(new DateTime(1385341200000l), new DateTime(1385665200000l), 1046.0)
		Assert.assertEquals(8, axis.ticks.size)
	}
	
}