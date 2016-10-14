package com.sirolf2009.samurai.test.renderer.chart

import org.junit.Test
import com.sirolf2009.samurai.renderer.chart.NumberAxis
import static extension com.sirolf2009.samurai.renderer.chart.NumberAxis.*
import static junit.framework.Assert.*

class TestNumberAxis {
	
	@Test
	def void testAutoRangerIndicator2() {
		NumberAxis.fromRange(0.0123456789, 0.11234567899, 263.3333333333333).ticks.forEach[println(it)]
		println()
		NumberAxis.fromRange(0.0123456789, 0.05, 263.3333333333333).ticks.forEach[println(it)]
		println()
		NumberAxis.fromRange(50, 57.5, 263.3333333333333).ticks.forEach[println(it)]
		println()
		NumberAxis.fromRange(804.13625, 1150.8899999999999, 263.3333333333333).ticks.forEach[println(it)]
	}
	
	@Test
	def void testPrettyNumber() {
		assertEquals(90.0, 92.49999.pretty())
		assertEquals(-70.0, -67.78831100000004.pretty())
		assertEquals(0.0, 0.pretty())
		assertEquals(-20.0, -17.99000000000001.pretty())
	}
	
}