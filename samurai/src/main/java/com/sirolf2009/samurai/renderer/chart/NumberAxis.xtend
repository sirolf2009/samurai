package com.sirolf2009.samurai.renderer.chart

import java.text.DecimalFormat
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class NumberAxis extends Axis {

	List<String> ticks
	double tick
	double minValue
	double maxValue
	boolean isVertical

	def static NumberAxis fromRange(double minValueUgly, double maxValue, double length) {
		val minValue = minValueUgly.pretty
		val range = (maxValue - minValue)
		val exponent = Math.log10(range)
		val unroundedTickSize = range / (((length / 32) as int) - 1)
		val x = Math.ceil(Math.log10(unroundedTickSize) - 1)
		val pow10x = Math.pow(10, x)
		val roundedTickRange = Math.ceil(unroundedTickSize / pow10x) * pow10x

		val format = if(exponent > 1) {
				"#,##0"
			} else if(exponent == 1) {
				"0"
			} else {
				val ratio = roundedTickRange / Math.pow(10, exponent)
				val ratioHasFrac = Math.rint(ratio) != ratio
				val formatterB = new StringBuilder("0")
				var n = if(ratioHasFrac) Math.abs(exponent) + 1 else Math.abs(exponent)
				if(n > 0) formatterB.append(".")
				for (var i = 0; i < n; i++) {
					formatterB.append("0")
				}
				formatterB.toString()
			}

		val formatter = new DecimalFormat(format)
		val ticks = new ArrayList()
		for (var i = minValue.pretty; i < maxValue; i += roundedTickRange) {
			ticks.add(formatter.format(i))
		}
		return new NumberAxis(ticks, roundedTickRange, minValueUgly, maxValue, true)
	}
	
	def static pretty(double value) {
    	val log = Math.floor(Math.log10(value))

    	val fraction = if(log > 1) {
        	4
    	} else {
    		1
    	}

    	Math.round(value * fraction * Math.pow(10, -log)) / fraction / Math.pow(10, -log)
	}
}
