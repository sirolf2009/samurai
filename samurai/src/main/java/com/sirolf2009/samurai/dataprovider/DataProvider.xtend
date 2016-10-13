package com.sirolf2009.samurai.dataprovider

import eu.verdelhan.ta4j.Tick
import eu.verdelhan.ta4j.TimeSeries
import java.util.ArrayList
import java.util.List
import javafx.concurrent.Task
import org.eclipse.xtend.lib.annotations.Accessors
import org.joda.time.DateTime
import org.joda.time.Period

abstract class DataProvider extends Task<TimeSeries> {
	
	@Accessors var Period period
	@Accessors var DateTime from
	@Accessors var DateTime to
	
	public var progress = 0
	
	def static List<Tick> buildEmptyTicks(DateTime beginTime, DateTime endTime, Period period) {
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