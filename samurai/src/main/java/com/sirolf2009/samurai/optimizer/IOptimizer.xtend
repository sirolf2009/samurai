package com.sirolf2009.samurai.optimizer

import com.sirolf2009.samurai.strategy.IStrategy

interface IOptimizer {
	
	def boolean canOptimize(IStrategy strategy)
	
}