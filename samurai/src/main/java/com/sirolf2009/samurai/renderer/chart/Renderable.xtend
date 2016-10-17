package com.sirolf2009.samurai.renderer.chart

import javafx.scene.canvas.GraphicsContext
import eu.verdelhan.ta4j.Tick

interface Renderable {
	
	def void render(GraphicsContext g, Tick tick)
	
}