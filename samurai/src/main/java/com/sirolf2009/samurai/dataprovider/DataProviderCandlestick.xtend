package com.sirolf2009.samurai.dataprovider

import eu.verdelhan.ta4j.Tick
import eu.verdelhan.ta4j.TimeSeries
import java.io.File
import java.util.ArrayList
import java.util.Scanner
import org.joda.time.DateTime
import com.sirolf2009.samurai.annotations.Register

class DataProviderCandlestick extends DataProvider {
	
	val String name
	val File file

	var progress = 0

	new(String file) {
		file = new File(class.getResource(file).toURI)
		name = file
	}

	new(File file) {
		this.file = file
		this.name = "bitcoincharts.com-" + file.name
	}

	override protected call() throws Exception {
		val scanner = new Scanner(file)
		val size = file.length
        val ticks = new ArrayList()
        
		updateMessage("Loading data")
		while(scanner.hasNextLine() && !isCancelled) {
			val line = scanner.nextLine()
			val data = line.split(",")
			val date = new DateTime(Long.parseLong(data.get(0))*1000)
			val open = Double.parseDouble(data.get(1))
			val high = Double.parseDouble(data.get(2))
			val low = Double.parseDouble(data.get(3))
			val close = Double.parseDouble(data.get(4))
			val volume = Double.parseDouble(data.get(5))
			ticks.add(new Tick(date, open, high, low, close, volume))
			progress += line.bytes.length
			updateProgress(progress, size)
		}
		return new TimeSeries(name, ticks)
	}
	
	@Register(name="OkCoin15", type="Built-In") static class DataProviderCandlestickOKCoin15 extends DataProviderCandlestick {
		
		new() {
			super(new File("data/okcoinCNY.candles15.csv"))
		}
		
	}
	
}