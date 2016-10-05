package com.sirolf2009.samurai.renderer

import eu.verdelhan.ta4j.TimeSeries
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext

interface IRenderer {
	
	def void drawTimeSeries(TimeSeries series, Canvas canvas, GraphicsContext g, int x, double scaleX)
	
}