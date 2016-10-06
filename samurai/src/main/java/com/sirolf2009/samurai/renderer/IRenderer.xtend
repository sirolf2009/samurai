package com.sirolf2009.samurai.renderer

import com.sirolf2009.samurai.renderer.chart.Chart
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext

interface IRenderer {
	
	def void drawChart(Chart chart, Canvas canvas, GraphicsContext g, int x, double scaleX)
	
}