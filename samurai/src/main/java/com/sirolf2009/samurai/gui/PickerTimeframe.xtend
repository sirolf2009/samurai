package com.sirolf2009.samurai.gui

import com.sirolf2009.samurai.Samurai
import java.time.LocalDate
import java.time.ZoneId
import java.util.Calendar
import javafx.beans.property.BooleanProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.control.DatePicker
import javafx.scene.control.Label
import javafx.scene.control.TitledPane
import javafx.scene.control.ToggleButton
import javafx.scene.control.ToggleGroup
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.layout.GridPane
import javafx.scene.layout.HBox
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.joda.time.DateTime
import org.joda.time.Period
import javafx.scene.control.Separator
import javafx.geometry.Orientation
import javafx.beans.property.SimpleObjectProperty
import org.eclipse.xtend.lib.annotations.Data
import javafx.beans.InvalidationListener

class PickerTimeframe extends TitledPane {

	@Accessors var BooleanProperty satisfiedProperty = new SimpleBooleanProperty(this, "satisfied", false)
	@Accessors var SimpleObjectProperty<Timeframe> timeframeProperty = new SimpleObjectProperty<Timeframe>(this, "timeframe")
	@Accessors var SimpleObjectProperty<Period> periodProperty = new SimpleObjectProperty<Period>(this, "period")
	@Accessors var SimpleObjectProperty<DateTime> fromProperty = new SimpleObjectProperty<DateTime>(this, "from")
	@Accessors var SimpleObjectProperty<DateTime> toProperty = new SimpleObjectProperty<DateTime>(this, "to")
	@Accessors var ToggleGroup group = new ToggleGroup()

	new() {
		super("Timeframe", null)
		val root = new VBox()
		content = root
		expanded = false
		root.children += new GridPane() => [
			val cal = Calendar.instance
			padding = new Insets(4)
			add(new Label("From"), 0, 0)
			add(new DatePicker(LocalDate.ofYearDay(cal.get(Calendar.YEAR), 1)) => [
				onAction = [fromProperty.set(new DateTime((source as DatePicker).value.atStartOfDay(ZoneId.systemDefault).toEpochSecond() * 1000))]
			], 1, 0)
			add(new Label("To"), 0, 1)
			add(new DatePicker(LocalDate.ofYearDay(cal.get(Calendar.YEAR), cal.get(Calendar.DAY_OF_YEAR) - 1)) => [
				onAction = [toProperty.set(new DateTime((source as DatePicker).value.atStartOfDay(ZoneId.systemDefault).toEpochSecond() * 1000))]
			], 1, 1)

			fromProperty.set(new DateTime(cal.get(Calendar.YEAR) - 1, 1, 1, 1, 0))
			toProperty.set(new DateTime(cal.get(Calendar.YEAR), 1, 1, 1, 0))
		]
		root.children += new Separator(Orientation.HORIZONTAL)
		root.children += new HBox(4, new Label("Period"), new HBox(
			new ToggleButtonPeriod(this, Period.minutes(1), "1"),
			new ToggleButtonPeriod(this, Period.minutes(3), "3"),
			new ToggleButtonPeriod(this, Period.minutes(15), "15"),
			new ToggleButtonPeriod(this, Period.minutes(30), "30"),
			new ToggleButtonPeriod(this, Period.hours(1), "1h"),
			new ToggleButtonPeriod(this, Period.hours(4), "4h"),
			new ToggleButtonPeriod(this, Period.days(1), "1d")
		) => [
			alignment = Pos.CENTER
		])
		group.selectedToggleProperty.addListener [ observable, old, newToggle |
			if(newToggle == null) {
				periodProperty.set(null)
				graphic = null
				satisfiedProperty.set(false)
			} else {
				periodProperty.set(group.selectedToggle.userData as Period)
				graphic = new ImageView(new Image(Samurai.getResourceAsStream("/ok.png")))
				satisfiedProperty.set(true)
			}
		]
		
		val InvalidationListener objectUpdater = [
			if(periodProperty.get != null && fromProperty.get != null && toProperty.get != null) {
				timeframeProperty.set(new Timeframe(periodProperty.get, fromProperty.get, toProperty.get))
			} else {
				timeframeProperty.set(null)
			}
		]
		periodProperty.addListener(objectUpdater)
		fromProperty.addListener(objectUpdater)
		toProperty.addListener(objectUpdater)
	}

	static class ToggleButtonPeriod extends ToggleButton {

		new(PickerTimeframe picker, Period period, String text) {
			super(text)
			toggleGroup = picker.group
			userData = period
		}

	}
	
	@Data public static class Timeframe {
		
		Period period
		DateTime from
		DateTime to
			
	}

}
