package com.sirolf2009.samurai.renderer.chart

import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.xbase.lib.Functions.Function1

@Data class NumberAxis extends Axis {
	
	double majorTick
	double minorTick
	Function1<Number, String> formatter
	
}