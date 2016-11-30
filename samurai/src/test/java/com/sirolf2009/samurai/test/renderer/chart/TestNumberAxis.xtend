package com.sirolf2009.samurai.test.renderer.chart

import org.junit.Test

import static junit.framework.Assert.*

import static extension com.sirolf2009.samurai.renderer.chart.NumberAxis.*

class TestNumberAxis {
	
	@Test
	def void testPrettyNumber() {
		assertEquals(90.0, 92.49999.pretty())
		assertEquals(-70.0, -67.78831100000004.pretty())
		assertEquals(0.0, 0.pretty())
		assertEquals(-20.0, -17.99000000000001.pretty())
	}
	
}