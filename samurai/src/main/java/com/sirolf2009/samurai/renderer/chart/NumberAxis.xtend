package com.sirolf2009.samurai.renderer.chart

import java.text.DecimalFormat
import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Data
import javafx.geometry.Bounds

@Data class NumberAxis extends Axis {

	double minValueData
	double maxValueData
	double minValue
	double maxValue
	boolean isVertical
	
	def map(double value) {
		val valueToAxis = if(minValueData < minValue) map(value, minValueData, maxValueData, minValue, maxValue) else value
		val valueOnChart = map(valueToAxis, minValue, maxValue, 0, if(isVertical) -bounds.height else bounds.width)
		valueOnChart
	}

	def static map(double x, double in_min, double in_max, double out_min, double out_max) {
		return out_min + ((out_max - out_min) / (in_max - in_min)) * (x - in_min)
	}

	def static NumberAxis fromRange(double minValueUgly, double maxValue, Bounds bounds, boolean isVertical) {
		return fromRange(minValueUgly, maxValue, bounds, isVertical, 32)
	}

	def static NumberAxis fromRange(double minValueUgly, double maxValue, Bounds bounds, boolean isVertical, double labels) {
		val minValue = if(minValueUgly.pretty() < maxValue) minValueUgly.pretty() else minValueUgly
		val range = (maxValue - minValue)
		
		if(range == 0) {
			return fromRange(minValueUgly - 1, maxValue+1, bounds, isVertical, labels)
		}
		
		val exponent = Math.log10(range)
		val unroundedTickSize = range / ((((if(isVertical) bounds.height else bounds.width) / labels) as int) - 1)
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
		for (var i = minValue; i < maxValue; i += roundedTickRange) {
			ticks.add(formatter.format(i))
		}
		
  //Bounds bounds, final List<String> ticks, final double tick, final double minValueData, final double maxValueData, final double minValue, final double maxValue, final double panelSize, final boolean isVertical) {
		return new NumberAxis(bounds, ticks, roundedTickRange, minValueUgly, maxValue, minValue, maxValue, isVertical)
	}
	
	def static pretty(double value) {
		if(value == 0) return 0
    	val log = Math.floor(Math.log10(Math.abs(value)))
    	
    	val fraction = if(log > 1) {
        	4
    	} else {
    		1
    	}

    	Math.round(value * fraction * Math.pow(10, -log)) / fraction / Math.pow(10, -log)
	}
}
