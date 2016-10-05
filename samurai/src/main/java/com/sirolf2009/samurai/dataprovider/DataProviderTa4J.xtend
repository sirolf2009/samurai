package com.sirolf2009.samurai.dataprovider

import ta4jexamples.loaders.CsvTradesLoader

class DataProviderTa4J extends DataProvider {
	
	override protected call() throws Exception {
		return CsvTradesLoader.loadBitstampSeries()
	}
	
}