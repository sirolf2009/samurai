package com.sirolf2009.samurai.criterion

import com.sirolf2009.samurai.indicator.IndicatorAbsoluteCashFlow
import eu.verdelhan.ta4j.Decimal
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.Trade
import eu.verdelhan.ta4j.TradesRecord
import eu.verdelhan.ta4j.analysis.criteria.AbstractAnalysisCriterion

class AbsoluteMaximumDrawdownCriterion extends AbstractAnalysisCriterion {

	override calculate(TimeSeries series, TradesRecord tradesRecord) {
		val cashFlow = new IndicatorAbsoluteCashFlow(series, tradesRecord)
		val maximumDrawdown = calculateMaximumDrawdown(series, cashFlow)
		return maximumDrawdown.toDouble()
	}

	override calculate(TimeSeries series, Trade trade) {
		if(trade !== null && trade.entry !== null && trade.exit !== null) {
			val cashFlow = new IndicatorAbsoluteCashFlow(series, trade)
			val maximumDrawdown = calculateMaximumDrawdown(series, cashFlow)
			return maximumDrawdown.toDouble()
		}
		return 0
	}

	override betterThan(double criterionValue1, double criterionValue2) {
		return criterionValue1 < criterionValue2;
	}

	def calculateMaximumDrawdown(TimeSeries series, IndicatorAbsoluteCashFlow cashFlow) {
		var maximumDrawdown = Decimal.ZERO
		var maxPeak = Decimal.ZERO
		for (var i = series.getBegin(); i <= series.getEnd(); i++) {
			val value = cashFlow.getValue(i)
			if(value.isGreaterThan(maxPeak)) {
				maxPeak = value
			}

			val drawdown = maxPeak.minus(value)
			if(drawdown.isGreaterThan(maximumDrawdown)) {
				maximumDrawdown = drawdown
			}
		}
		return maximumDrawdown
	}

}
