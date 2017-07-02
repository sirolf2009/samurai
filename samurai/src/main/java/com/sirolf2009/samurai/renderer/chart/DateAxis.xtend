package com.sirolf2009.samurai.renderer.chart

import java.text.SimpleDateFormat
import java.time.ZonedDateTime
import java.util.ArrayList
import java.util.List
import javafx.geometry.Bounds
import org.eclipse.xtend.lib.annotations.Data
import java.util.Date

@Data class DateAxis extends Axis {

	static val SECOND = 1000
	static val MINUTE = SECOND * 60
	static val HOUR = MINUTE * 60
	static val DAY = HOUR * 24
	static val WEEK = DAY * 7
	static val MONTH = WEEK * 52

	static val SECOND_SPEC = new TickSpecification(SECOND, new SimpleDateFormat("HH:mm:ss"), #[1, 2, 3, 5, 10, 15, 30])
	static val MINUTE_SPEC = new TickSpecification(MINUTE, new SimpleDateFormat("HH:mm"), #[1, 2, 3, 5, 10, 15, 30])
	static val HOUR_SPEC = new TickSpecification(HOUR, new SimpleDateFormat("MM/dd HH:mm"), #[1, 2, 3, 4, 6, 8, 12])
	static val DAY_SPEC = new TickSpecification(DAY, new SimpleDateFormat("MM/dd"), #[1, 2, 7])
	static val WEEK_SPEC = new TickSpecification(WEEK, new SimpleDateFormat("yyyy/MM/dd"), #[1, 2, 4])
	static val MONTH_SPEC = new TickSpecification(MONTH, new SimpleDateFormat("yyyy/MM"), #[1, 2, 3, 4, 6])

	ZonedDateTime from
	ZonedDateTime to

	def static DateAxis fromRange(ZonedDateTime from, ZonedDateTime to, Bounds bounds) {
		val range = (to.toEpochSecond - from.toEpochSecond) / bounds.width * 400 // millis per 400 pixels
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
		for (var i = from.toEpochSecond; i < to.toEpochSecond; i += tick) {
			ticks.add(format.format(new Date(i*1000)))
		}
		return new DateAxis(bounds, ticks, tick, from, to)
	}

	@Data static class TickSpecification {

		long tick
		SimpleDateFormat format
		List<Integer> multipliers

		def multipliedTick(double range) {
			val target = 3 // 3 labels per 400 pixels
			multipliers.map[it*tick -> Math.abs(target-(range/(tick*it)))].min[a,b| a.value.compareTo(b.value)].key
		}

	}

}
