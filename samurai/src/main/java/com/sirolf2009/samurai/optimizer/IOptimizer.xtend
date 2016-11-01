package com.sirolf2009.samurai.optimizer

import com.sirolf2009.samurai.gui.picker.PickerOptimizerParameters
import com.sirolf2009.samurai.strategy.IStrategy

interface IOptimizer {
	
	def boolean canOptimize(IStrategy strategy)
	def void populateParameters(PickerOptimizerParameters parameterPane, IStrategy strategy)
	
}