package com.sirolf2009.samurai.dataprovider

import eu.verdelhan.ta4j.TimeSeries
import javafx.concurrent.Task
import org.joda.time.DateTime
import org.joda.time.Period
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors abstract class DataProvider extends Task<TimeSeries> {
	
	var Period period
	var DateTime from
	var DateTime to
	
}