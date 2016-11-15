package com.sirolf2009.samurai.optimizer

import com.sirolf2009.samurai.gui.picker.PickerOptimizerParameters
import com.sirolf2009.samurai.strategy.IStrategy
import javafx.scene.control.Tab
import com.sirolf2009.samurai.gui.SetupOptimize.OptimizeSetup
import com.sirolf2009.samurai.gui.SamuraiStatusBar

interface IOptimizer {
	
	def boolean canOptimize(IStrategy strategy)
	def void populateParameters(IStrategy strategy, PickerOptimizerParameters parameterPane)
	def void optimize(OptimizeSetup setup, PickerOptimizerParameters parameterPane, Tab optimizationTab, SamuraiStatusBar statusBar)
	
}