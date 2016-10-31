package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.Samurai
import com.sirolf2009.samurai.dataprovider.DataProviderBitcoinCharts
import java.io.File
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.scene.control.TitledPane
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import org.eclipse.xtend.lib.annotations.Accessors

import static extension com.sirolf2009.samurai.util.GUIUtil.*
import javafx.beans.property.SimpleObjectProperty
import java.util.function.Supplier
import com.sirolf2009.samurai.dataprovider.DataProvider

class PickerDataprovider extends TitledPane {

	@Accessors val providerProperty = new SimpleObjectProperty<Supplier<DataProvider>>(this, "provider")
	@Accessors val satisfiedProperty = new SimpleBooleanProperty(this, "satisfied", false)

	new() {
		super("Data", null)
		expanded = false
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
					providerProperty.set((item as TreeItemDataProvider).provider)
					satisfiedProperty.set(true)
					graphic = new ImageView(new Image(Samurai.getResourceAsStream("/ok.png")))
				} else {
					providerProperty.set(null)
					satisfiedProperty.set(false)
					graphic = null
				}
			]
			expandAllNodes
		]
	}

}
