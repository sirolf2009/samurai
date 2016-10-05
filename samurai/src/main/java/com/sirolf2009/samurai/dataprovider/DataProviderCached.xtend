package com.sirolf2009.samurai.dataprovider

import com.sirolf2009.duke.core.DBEntity
import com.sirolf2009.duke.core.Duke
import com.sirolf2009.duke.core.ID
import eu.verdelhan.ta4j.TimeSeries
import org.eclipse.xtend.lib.annotations.Accessors
import org.joda.time.DateTime
import org.joda.time.Period

abstract class DataProviderCached extends DataProvider {

	@Accessors val String name
	val Duke duke

	new(String name) {
		this.name = name
		duke = new Duke("db/data", "com.sirolf2009.samurai")
	}

//	override load(Period period, DateTime from, DateTime to) {
//		new Thread([
//			var TimeSeries series
//			val zero = new DateTime(0);
//			val millis = period.toDurationFrom(zero).getMillis()
//			for (var i = from.millis; i < to.millis; i += millis) {
//				val newSeries = loadOrRetrieve(period, new DateTime(i), new DateTime(i + period.millis))
//				if(series == null) {
//					series = newSeries;
//				} else {
//					for (var j = 0; j < newSeries.tickCount; j++) {
//						series.addTick(newSeries.getTick(j))
//					}
//				}
//			}
//		]).start()
//		return null
//	}

	def TimeSeries loadOrRetrieve(Period period, DateTime from, DateTime to) {
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

	def TimeSeries loadExternal(Period period, DateTime from, DateTime to)

	@DBEntity public static class Data {

		@ID String name
		TimeSeries timeseries

	}

}
