package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.Samurai
import com.sirolf2009.samurai.annotations.Register
import com.sirolf2009.samurai.dataprovider.DataProviderBitcoinCharts
import com.sirolf2009.samurai.strategy.IStrategy
import com.sirolf2009.samurai.strategy.Param
import java.io.File
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.geometry.Insets
import javafx.scene.control.Label
import javafx.scene.control.Separator
import javafx.scene.control.TitledPane
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.layout.GridPane
import javafx.scene.layout.VBox
import org.reflections.Reflections
import org.reflections.scanners.SubTypesScanner
import org.reflections.scanners.TypeAnnotationsScanner

import static extension com.sirolf2009.samurai.util.GUIUtil.*
import org.eclipse.xtend.lib.annotations.Accessors

class SimulationSetup extends VBox {

	@Accessors val TitledPane parametersPane
	@Accessors val GridPane parametersGrid
	@Accessors val TimeframePicker timeframePicker

	@Accessors var TreeItemDataProvider provider
	@Accessors var IStrategy strategy

	new() {
		val dataPane = new TitledPane("Data", null)
		val strategyPane = new TitledPane("Strategy", null)
		parametersPane = new TitledPane("Parameters", null)
		parametersGrid = new GridPane() => [
			padding = new Insets(4)
		]
		timeframePicker = new TimeframePicker() => [
			satisfiedProperty.addListener [ observable, old, newValue |
				if(newValue) {
					parametersPane.graphic = new ImageView(new Image(Samurai.getResourceAsStream("/ok.png")))
				} else {
					parametersPane.graphic = null
				}
			]
		]

		children += dataPane => [
			content = new TreeView => [
				root = new TreeItem("") => [
					children += new TreeItem("BitcoinCharts") => [
						children += new TreeItemDataProvider("BTCCNY - OkCoin", [new DataProviderBitcoinCharts(new File("data/okcoinCNY.csv"))])
						children += new TreeItemDataProvider("BTCUSD - OkCoin", [new DataProviderBitcoinCharts(new File("data/bitfinexUSD.csv"))])
						children += new TreeItemDataProvider("BTCUSD - Bitstamp", [new DataProviderBitcoinCharts(new File("data/bitstampUSD.csv"))])
					]
				]
				showRoot = false
				selectionModel.selectedItemProperty.addListener [
					val item = (it as ReadOnlyObjectProperty<TreeItem<String>>).value
					if(item instanceof TreeItemDataProvider) {
						provider = item as TreeItemDataProvider
						dataPane.graphic = new ImageView(new Image(Samurai.getResourceAsStream("/ok.png")))
						dataPane.expanded = false
						strategyPane.expanded = true
						parametersPane.expanded = false
					}
				]
				expandAllNodes
			]
		]
		children += strategyPane => [
			expanded = false
			content = new TreeView => [
				root = new TreeItem("Strategy") => [
					children += new TreeItem("Built-In") => [
						val reflections = new Reflections("", new SubTypesScanner(), new TypeAnnotationsScanner())
						reflections.getTypesAnnotatedWith(Register).filter[interfaces.findFirst[IStrategy.isAssignableFrom(it)] != null].forEach [ strategyClass |
							val name = (strategyClass.annotations.findFirst[annotationType == Register] as Register).name
							val strategy = strategyClass.newInstance() as IStrategy
							children += new TreeItemStrategy(name, strategy)
						]
					]
				]
				showRoot = false
				selectionModel.selectedItemProperty.addListener [
					val item = (it as ReadOnlyObjectProperty<TreeItem<String>>).value
					if(item instanceof TreeItemStrategy) {
						strategy = item.strategy
						strategyPane.graphic = new ImageView(new Image(Samurai.getResourceAsStream("/ok.png")))
						dataPane.expanded = false
						strategyPane.expanded = false
						parametersPane.expanded = true

						strategy.class.fields.filter [
							annotations.findFirst[it.annotationType == Param] != null
						].forEach [ field, index |
							parametersGrid.add(new Label(field.name), 0, index)
							if(field.type == Integer || field.type == Integer.TYPE) {
								parametersGrid.add(new NumberSpinner(field.get(strategy) as Integer, 1), 1, index)
							}
						]
					}
				]
				expandAllNodes
			]
		]
		children += parametersPane => [
			expanded = false
			content = new VBox => [
				children += parametersGrid
				children += new Separator()
				children += timeframePicker
			]
		]
	}

}
