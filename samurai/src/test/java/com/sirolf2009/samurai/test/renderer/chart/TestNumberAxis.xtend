package com.sirolf2009.samurai.test.renderer.chart

import org.junit.Test
import com.sirolf2009.samurai.renderer.chart.NumberAxis

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
	
}