package com.sirolf2009.samurai.dataprovider

import eu.verdelhan.ta4j.Tick
import eu.verdelhan.ta4j.TimeSeries
import java.io.File
import java.util.ArrayList
import java.util.LinkedList
import java.util.List
import java.util.Scanner
import org.joda.time.DateTime
import org.joda.time.Period

class DataProviderBitcoinCharts extends DataProvider {
	
	val String name
	val File file
	
	var progress = 0
	
	new(String file) {
		this(new File(file))
	}
	
	new(File file) {
		this.file = file
		this.name = "bitcoincharts.com-"+file.name
	}
	
	override protected call() throws Exception {
		val ticks = buildEmptyTicks(from, to, period)
		val ticksQueue = new LinkedList(ticks)
		val scanner = new Scanner(file)
		val size = file.length
		
		while(scanner.hasNextLine() && !isCancelled) {
			val line = scanner.nextLine()
			val data = line.split(",")
			val time = new DateTime(Long.parseLong(data.get(0))*1000)
			while(!ticksQueue.peek.inPeriod(time)) {
				ticksQueue.poll
			}
			ticksQueue.peek => [
				val price = Double.parseDouble(data.get(1))
				val amount = Double.parseDouble(data.get(2))
				addTrade(amount, price)
				updateMessage("Loading "+time.getYear+"-"+time.getMonthOfYear+"-"+time.getDayOfMonth)
			]
			progress += line.bytes.length
			updateProgress(progress, size)
		}
		removeEmptyTicks(ticks)

		return new TimeSeries(name, ticks)
	}

	def static List<Tick> buildEmptyTicks(DateTime beginTime, DateTime endTime, Period period) {
		val emptyTicks = new ArrayList<Tick>()

		var tickEndTime = beginTime
		do {
			tickEndTime = tickEndTime.plus(period)
			emptyTicks.add(new Tick(period, tickEndTime))
		} while(tickEndTime.isBefore(endTime))

		return emptyTicks;
	}

	def removeEmptyTicks(List<Tick> ticks) {
		updateMessage("Removing gaps")
		val size = ticks.size
		progress = 0
		ticks.removeAll(ticks.filter[
			progress += 1
			updateProgress(progress, size)
			trades == 0
		])
	}
	
}
