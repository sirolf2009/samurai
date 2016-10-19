package com.sirolf2009.samurai.renderer.chart

import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import org.joda.time.DateTime
import org.joda.time.format.DateTimeFormat
import java.util.ArrayList
import org.joda.time.format.DateTimeFormatter
import javafx.geometry.Bounds

@Data class DateAxis extends Axis {

	static val SECOND = 1000
	static val MINUTE = SECOND * 60
	static val HOUR = MINUTE * 60
	static val DAY = HOUR * 24
	static val WEEK = DAY * 7
	static val MONTH = WEEK * 52

	static val SECOND_SPEC = new TickSpecification(SECOND, DateTimeFormat.forPattern("HH:mm:ss"), #[1, 2, 3, 5, 10, 15, 30])
	static val MINUTE_SPEC = new TickSpecification(MINUTE, DateTimeFormat.forPattern("HH:mm"), #[1, 2, 3, 5, 10, 15, 30])
	static val HOUR_SPEC = new TickSpecification(HOUR, DateTimeFormat.forPattern("MM/dd HH:mm"), #[1, 2, 3, 4, 6, 8, 12])
	static val DAY_SPEC = new TickSpecification(DAY, DateTimeFormat.forPattern("MM/dd"), #[1, 2, 7])
	static val WEEK_SPEC = new TickSpecification(WEEK, DateTimeFormat.forPattern("yyyy/MM/dd"), #[1, 2, 4])
	static val MONTH_SPEC = new TickSpecification(MONTH, DateTimeFormat.forPattern("yyyy/MM"), #[1, 2, 3, 4, 6])

	List<String> ticks
	long tick
	DateTime from
	DateTime to
	val Bounds bounds

	def static DateAxis fromRange(DateTime from, DateTime to, Bounds bounds) {
		val range = (to.millis - from.millis) / bounds.width * 400 // millis per 400 pixels
		val tickSpec = if(range < MINUTE * 2) {
				SECOND_SPEC
			} else if(range < HOUR * 2) {
				MINUTE_SPEC
			} else if(range < DAY * 2) {
				HOUR_SPEC
			} else if(range < WEEK * 2) {
				DAY_SPEC
			} else if(range < MONTH * 2) {
				WEEK_SPEC
			} else {
				MONTH_SPEC
			}
		val tick = tickSpec.multipliedTick(range)
		val format = tickSpec.format

		val ticks = new ArrayList()
		for (var i = from.millis; i < to.millis; i += tick) {
			ticks.add(format.print(new DateTime(i)))
		}
		return new DateAxis(ticks, tick, from, to, bounds)
	}

	@Data static class TickSpecification {

		long tick
		DateTimeFormatter format
		List<Integer> multipliers

		def multipliedTick(double range) {
			val target = 3 // 3 labels per 400 pixels
			multipliers.map[it*tick -> Math.abs(target-(range/(tick*it)))].min[a,b| a.value.compareTo(b.value)].key
		}

	}

}
