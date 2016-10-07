package com.sirolf2009.samurai.renderer

import com.sirolf2009.samurai.renderer.chart.ChartData
import javafx.scene.canvas.Canvas
import javafx.scene.canvas.GraphicsContext

interface IRenderer {
	
	def void drawChart(ChartData chart, Canvas canvas, GraphicsContext g, int x, double scaleX)
	
	def double getTickSize()
	
}