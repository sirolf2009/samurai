package com.sirolf2009.samurai.dataprovider

import eu.verdelhan.ta4j.Tick
import eu.verdelhan.ta4j.TimeSeries
import java.time.Duration
import java.time.ZonedDateTime
import java.util.ArrayList
import java.util.List
import javafx.concurrent.Task
import org.eclipse.xtend.lib.annotations.Accessors

abstract class DataProvider extends Task<TimeSeries> {
	
	@Accessors var Duration period
	@Accessors var ZonedDateTime from
	@Accessors var ZonedDateTime to
	
	public var progress = 0
	
	def static List<Tick> buildEmptyTicks(ZonedDateTime beginTime, ZonedDateTime endTime, Duration period) {
		val emptyTicks = new ArrayList<Tick>()

		var tickEndTime = beginTime
		do {
			tickEndTime = tickEndTime.plus(period)
			emptyTicks.add(new Tick(period, tickEndTime))
		} while(tickEndTime.isBefore(endTime))

		return emptyTicks
	}

	def removeEmptyTicks(List<Tick> ticks) {
		updateMessage("Removing gaps")
		val size = ticks.size
		progress = 0
		ticks.removeAll(ticks.filter[
			progress += 1
			updateProgress(progress, size)
			trades == 0
		])
	}
	
}