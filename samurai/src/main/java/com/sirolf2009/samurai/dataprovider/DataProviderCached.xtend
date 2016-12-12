package com.sirolf2009.samurai.dataprovider

import com.sirolf2009.duke.core.DBEntity
import com.sirolf2009.duke.core.Duke
import com.sirolf2009.duke.core.ID
import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.TimeSeries
import java.util.ArrayList
import java.util.LinkedList
import org.eclipse.xtend.lib.annotations.Accessors
import org.joda.time.DateTime
import org.joda.time.Period

abstract class DataProviderCached extends DataProvider {

	static val MINUTE = new Period(1000 * 60)
	static val DAY = new Period(1000 * 60 * 60 * 24)

	@Accessors val String name
	val Duke duke

	new(String name) {
		this.name = name
		duke = new Duke("db/data", "com.sirolf2009.samurai")
	}

	override protected call() throws Exception {
		val zero = new DateTime(0)
		if(period.toDurationFrom(zero) >= DAY.toDurationFrom(zero)) {
			loadAndCombine(DAY, period)
		} else if(period.toDurationFrom(zero) >= MINUTE.toDurationFrom(zero)) {
			loadAndCombine(MINUTE, period)
		} else {
			throw new RuntimeException("Tick type not (yet) supported")
		}
	}

	def loadAndCombine(Period periodData, Period periodCombined) throws Exception {
		val TimeSeries series = new TimeSeries(name)
		val zero = new DateTime(0)
		val millis = periodData.toDurationFrom(zero).getMillis()
		val startIndeces = new ArrayList()
		updateMessage("Searching for data")
		for (var i = from.millis; i < to.millis; i += millis) {
			startIndeces.add(i)
		}
		val sizeData = startIndeces.size
		val ticksData = startIndeces.map [
			val time = new DateTime(it)
			val seriesDataPeriod = loadOrRetrieve(periodData, time, new DateTime(it + millis))
			updateMessage("Loading " + time.getYear + "-" + time.getMonthOfYear + "-" + time.getDayOfMonth)
			progress += 1
			updateProgress(progress, sizeData)
			(0 ..< seriesDataPeriod.tickCount).map [
				series.getTick(it)
			]
		].flatten

		val ticks = buildEmptyTicks(from, to, period)
		val ticksQueue = new LinkedList(ticks)
		val size = ticksData.size

		ticksData.forEach [
			val time = it.endTime
			while(!ticksQueue.peek.inPeriod(time)) {
				ticksQueue.poll
			}
			val amount = amount.dividedBy(Decimal.valueOf(4))
			val open = openPrice
			val high = maxPrice
			val low = minPrice
			val close = closePrice
			ticksQueue.peek => [
				addTrade(amount, open)
				addTrade(amount, high)
				addTrade(amount, low)
				addTrade(amount, close)
				updateMessage("Combining " + time.getYear + "-" + time.getMonthOfYear + "-" + time.getDayOfMonth)
			]
			progress += 1
			updateProgress(progress, size)
		]
		removeEmptyTicks(ticks)
		return new TimeSeries(name, ticks)
	}

	def TimeSeries loadOrRetrieve(Period period, DateTime from, DateTime to) throws Exception {
		if(duke.exists(getNameForPeriod(period, from, to), Data)) {
			return duke.read(getNameForPeriod(period, from, to), Data).timeseries
		} else {
			val series = loadExternal(period, from, to)
			duke.save(new Data(getNameForPeriod(period, from, to), series))
			return series
		}
	}

	def String getNameForPeriod(Period period, DateTime from, DateTime to) {
		return name + "_" + period + "_" + from + "_" + to
	}

	def TimeSeries loadExternal(Period period, DateTime from, DateTime to) throws Exception

	@DBEntity public static class Data {

		@ID String name
		TimeSeries timeseries

	}

}
