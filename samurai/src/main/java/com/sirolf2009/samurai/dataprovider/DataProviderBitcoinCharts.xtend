package com.sirolf2009.samurai.dataprovider

import eu.verdelhan.ta4j.TimeSeries
import java.io.File
import java.util.LinkedList
import java.util.Scanner
import org.joda.time.DateTime

class DataProviderBitcoinCharts extends DataProvider {

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
		val ticks = buildEmptyTicks(from, to, period)
		val ticksQueue = new LinkedList(ticks)
		val scanner = new Scanner(file)
		val size = file.length

		updateMessage("Loading data")
		while(scanner.hasNextLine() && !isCancelled) {
			val line = scanner.nextLine()
			val data = line.split(",")
			val time = new DateTime(Long.parseLong(data.get(0)) * 1000)
			while(ticksQueue.size > 0 && !ticksQueue.peek.inPeriod(time)) {
				ticksQueue.poll
			}
			if(ticksQueue.size > 0) {
				ticksQueue.peek => [
					val price = Double.parseDouble(data.get(1))
					val amount = Double.parseDouble(data.get(2))
					addTrade(amount, price)
					updateMessage("Loading " + time.getYear + "-" + time.getMonthOfYear + "-" + time.getDayOfMonth)
				]
			}
			progress += line.bytes.length
			updateProgress(progress, size)
		}
		removeEmptyTicks(ticks)

		return new TimeSeries(name, ticks)
	}

}
