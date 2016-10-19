package com.sirolf2009.samurai.renderer

import com.sirolf2009.samurai.renderer.chart.DateAxis
import javafx.scene.canvas.GraphicsContext

interface IRenderer {
	
	def void drawXAxis(DateAxis axis, GraphicsContext g)
	
}