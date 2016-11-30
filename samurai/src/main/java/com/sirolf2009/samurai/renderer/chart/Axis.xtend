package com.sirolf2009.samurai.renderer.chart

import org.eclipse.xtend.lib.annotations.Data
import javafx.geometry.Bounds
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

@Data @Accessors class Axis {
	
	val Bounds bounds
	val List<String> ticks
	val double tick
	
}