package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.criterion.AbsoluteProfitCriterion
import com.sirolf2009.samurai.indicator.IndicatorAbsoluteCashFlow
import com.sirolf2009.samurai.renderer.chart.Chart
import com.sirolf2009.samurai.renderer.chart.ChartData
import com.sirolf2009.samurai.renderer.chart.ChartIndicator
import com.sirolf2009.samurai.renderer.chart.ChartPrice
import com.sirolf2009.samurai.strategy.IStrategy
import eu.verdelhan.ta4j.TimeSeries
import eu.verdelhan.ta4j.TradesRecord
import eu.verdelhan.ta4j.analysis.criteria.AverageProfitCriterion
import eu.verdelhan.ta4j.analysis.criteria.AverageProfitableTradesCriterion
import eu.verdelhan.ta4j.analysis.criteria.BuyAndHoldCriterion
import eu.verdelhan.ta4j.analysis.criteria.MaximumDrawdownCriterion
import eu.verdelhan.ta4j.analysis.criteria.NumberOfTradesCriterion
import eu.verdelhan.ta4j.analysis.criteria.RewardRiskRatioCriterion
import eu.verdelhan.ta4j.analysis.criteria.TotalProfitCriterion
import java.text.DecimalFormat
import java.util.ArrayList
import javafx.application.Platform
import javafx.beans.value.ChangeListener
import javafx.beans.value.ObservableValue
import javafx.geometry.Insets
import javafx.scene.control.Label
import javafx.scene.control.Tab
import javafx.scene.control.TabPane
import javafx.scene.control.TableColumn
import javafx.scene.control.TableColumn.CellDataFeatures
import javafx.scene.control.TableView
import javafx.scene.layout.AnchorPane
import javafx.scene.layout.Background
import javafx.scene.layout.BackgroundFill
import javafx.scene.layout.Border
import javafx.scene.layout.BorderStroke
import javafx.scene.layout.BorderStrokeStyle
import javafx.scene.layout.BorderWidths
import javafx.scene.layout.CornerRadii
import javafx.scene.layout.GridPane
import javafx.scene.paint.Color
import javafx.util.Callback
import xtendfx.beans.FXBindable

import static extension com.sirolf2009.samurai.util.GUIUtil.*

class TabPaneBacktest extends TabPane {

	static val moneyFormat = new DecimalFormat("$###,###,###,##0.00")
	var Chart chart

	new(IStrategy strategy, TradesRecord tradingRecord, TimeSeries series) {
		background = new Background(new BackgroundFill(Color.WHITESMOKE, CornerRadii.EMPTY, Insets.EMPTY))

		new Tab("Details") => [
			val details = new GridPane()
			details.setMinSize(Double.MAX_VALUE, Double.MAX_VALUE)
			val getLabel = [ String text |
				new Label(text) => [
					border = new Border(new BorderStroke(Color.BLACK, BorderStrokeStyle.SOLID, CornerRadii.EMPTY, BorderWidths.DEFAULT))
				]
			]
			val addDetail = [ int row, String text, Object value |
				details.add(getLabel.apply(text), 0, row)
				details.add(getLabel.apply(value + ""), 1, row)
			]

			addDetail.apply(0, "Net profit", new TotalProfitCriterion().calculate(series, tradingRecord))
			addDetail.apply(1, "# Trades", new NumberOfTradesCriterion().calculate(series, tradingRecord) as int)
			addDetail.apply(2, "% Profitable", new AverageProfitableTradesCriterion().calculate(series, tradingRecord) * 100)
			addDetail.apply(3, "Max drawdown", new MaximumDrawdownCriterion().calculate(series, tradingRecord))
			addDetail.apply(4, "Average profit per trade", new AverageProfitCriterion().calculate(series, tradingRecord))
			addDetail.apply(5, "Reward risk ratio", new RewardRiskRatioCriterion().calculate(series, tradingRecord))
			addDetail.apply(6, "Buy and Hold ratio", new BuyAndHoldCriterion().calculate(series, tradingRecord))

			details.showGridLines()
			details.stretchGrid(1, 6)

			val container = new AnchorPane(details) => [
				minWidth = 0
				minHeight = 0
				AnchorPane.setBottomAnchor(details, 0D)
				AnchorPane.setTopAnchor(details, 0D)
				AnchorPane.setLeftAnchor(details, 0D)
				AnchorPane.setRightAnchor(details, 0D)
			]
			content = container
			tabs += it
		]
		new Tab("Chart") => [
			val canvas = new ResizableCanvas(100, 100)
			val container = new AnchorPane(canvas)
			container.minWidth = 0
			container.minHeight = 0
			canvas.widthProperty.bind(container.widthProperty())
			canvas.heightProperty.bind(container.heightProperty())
			AnchorPane.setBottomAnchor(canvas, 0D)
			AnchorPane.setTopAnchor(canvas, 0D)
			AnchorPane.setLeftAnchor(canvas, 0D)
			AnchorPane.setRightAnchor(canvas, 0D)
			content = container
			tabs += it
			Platform.runLater [
				chart = new ChartPrice(canvas, series, new ChartData(series, tradingRecord, strategy.indicators(series), new ArrayList()))
				val ChangeListener<? super Number> onResize = [
					chart.draw()
				]
				container.widthProperty().addListener(onResize)
				container.heightProperty().addListener(onResize)
				chart.draw()
			]
		]
		new Tab("Profit") => [
			val canvas = new ResizableCanvas(100, 100)
			val container = new AnchorPane(canvas)
			container.minWidth = 0
			container.minHeight = 0
			canvas.widthProperty.bind(container.widthProperty())
			canvas.heightProperty.bind(container.heightProperty())
			AnchorPane.setBottomAnchor(canvas, 0D)
			AnchorPane.setTopAnchor(canvas, 0D)
			AnchorPane.setLeftAnchor(canvas, 0D)
			AnchorPane.setRightAnchor(canvas, 0D)
			content = container
			tabs += it
			Platform.runLater [
				chart = new ChartIndicator(canvas, new IndicatorAbsoluteCashFlow(series, tradingRecord), new ChartData(series, tradingRecord, strategy.indicators(series), new ArrayList()))
				chart.fitAll()
				val ChangeListener<? super Number> onResize = [
					chart.draw()
				]
				container.widthProperty().addListener(onResize)
				container.heightProperty().addListener(onResize)
				chart.draw()
			]
		]
		new Tab("Trades") => [
			val table = new TableView<TableTrade>()

			val nrCol = new TableColumn("Nr")
			nrCol.cellValueFactory = new Callback<CellDataFeatures<TableTrade, String>, ObservableValue<String>> {
				override call(CellDataFeatures<TableTrade, String> param) {
					return param.value.nrProperty
				}
			}
			val directionCol = new TableColumn("Direction")
			directionCol.cellValueFactory = new Callback<CellDataFeatures<TableTrade, String>, ObservableValue<String>> {
				override call(CellDataFeatures<TableTrade, String> param) {
					return param.value.directionProperty
				}
			}
			val fromCol = new TableColumn("From")
			fromCol.cellValueFactory = new Callback<CellDataFeatures<TableTrade, String>, ObservableValue<String>> {
				override call(CellDataFeatures<TableTrade, String> param) {
					return param.value.fromProperty
				}
			}
			val toCol = new TableColumn("To")
			toCol.cellValueFactory = new Callback<CellDataFeatures<TableTrade, String>, ObservableValue<String>> {
				override call(CellDataFeatures<TableTrade, String> param) {
					return param.value.toProperty
				}
			}
			val entryCol = new TableColumn("Entry")
			entryCol.cellValueFactory = new Callback<CellDataFeatures<TableTrade, String>, ObservableValue<String>> {
				override call(CellDataFeatures<TableTrade, String> param) {
					return param.value.entryProperty
				}
			}
			val exitCol = new TableColumn("Exit")
			exitCol.cellValueFactory = new Callback<CellDataFeatures<TableTrade, String>, ObservableValue<String>> {
				override call(CellDataFeatures<TableTrade, String> param) {
					return param.value.exitProperty
				}
			}
			val profitCol = new TableColumn("Profit")
			profitCol.cellValueFactory = new Callback<CellDataFeatures<TableTrade, String>, ObservableValue<String>> {
				override call(CellDataFeatures<TableTrade, String> param) {
					return param.value.profitProperty
				}
			}

			table.getColumns().addAll(nrCol, directionCol, fromCol, toCol, entryCol, exitCol, profitCol)
			table.columnResizePolicy = TableView.CONSTRAINED_RESIZE_POLICY

			val profitCalc = new AbsoluteProfitCriterion()
			tradingRecord.sortWith[a,b|a.entry.index.compareTo(b.entry.index)].forEach [ trade, index |
				table.items.add(new TableTrade() => [
					nr = index + ""
					direction = if(trade.entry.buy) "LONG" else "SHORT"
					from = series.getTick(trade.entry.index).endTime + ""
					to = series.getTick(trade.exit.index).endTime + ""
					entry = moneyFormat.format(trade.entry.price.toDouble)
					exit = moneyFormat.format(trade.exit.price.toDouble)
					profit = moneyFormat.format(profitCalc.calculate(series, trade))
				])
			]

			val container = new AnchorPane(table) => [
				minWidth = 0
				minHeight = 0
				AnchorPane.setBottomAnchor(table, 0D)
				AnchorPane.setTopAnchor(table, 0D)
				AnchorPane.setLeftAnchor(table, 0D)
				AnchorPane.setRightAnchor(table, 0D)
			]
			content = container
			tabs += it
		]
	}

	@FXBindable static class TableTrade {

		String nr
		String direction
		String from
		String to
		String entry
		String exit
		String profit

	}

}
