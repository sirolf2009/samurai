package com.sirolf2009.samurai.renderer.chart

import org.eclipse.xtend.lib.annotations.Data
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.Indicator
import java.util.List

@Data class ChartData {
	
	TimeSeries timeseries
	List<Indicator<?>> indicators
	
}