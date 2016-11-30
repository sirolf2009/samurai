package com.sirolf2009.samurai.renderer

import com.sirolf2009.samurai.renderer.chart.Axis
import javafx.scene.canvas.GraphicsContext

interface IRenderer {
	
	def void drawXAxis(Axis axis, GraphicsContext g)
	
}