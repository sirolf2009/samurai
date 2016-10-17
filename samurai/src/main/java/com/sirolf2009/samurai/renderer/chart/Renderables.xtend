package com.sirolf2009.samurai.renderer.chart

import javafx.scene.paint.Color

abstract class Renderables {
	
	public static val Renderable arrowUp = [it,tick|
		fill = Color.GREEN
		fillPolygon(
			#[-4, 0, 4, 1, 1, -3, -3],
			#[4, 0, 4, 4, 8, 8, 4],
			7
		)
	]
	
	public static val Renderable arrowDown = [it,tick|
		fill = Color.RED
		fillPolygon(
			#[-4, 0, 4, 1, 1, -3, -3],
			#[4, 8, 4, 4, 0, 0, 4],
			7
		)
	]
	
}