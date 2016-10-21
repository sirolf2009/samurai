package com.sirolf2009.samurai.gui

import java.time.LocalDate
import java.util.Calendar
import javafx.beans.property.BooleanProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.control.DatePicker
import javafx.scene.control.Label
import javafx.scene.control.ToggleButton
import javafx.scene.control.ToggleGroup
import javafx.scene.layout.GridPane
import javafx.scene.layout.HBox
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.joda.time.Period

class TimeframePicker extends VBox {

	@Accessors var BooleanProperty satisfiedProperty = new SimpleBooleanProperty(false)
	@Accessors var Period period
	@Accessors var ToggleGroup group = new ToggleGroup()

	new() {
		children += new HBox(4, new Label("Period"), new HBox(
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
		group.selectedToggleProperty.addListener[observable, old, newToggle|
			if(newToggle == null) {
				period = null
				satisfiedProperty.set(false)
			} else {
				period = group.selectedToggle.userData as Period
				satisfiedProperty.set(true)
			}
		]
		children += new GridPane() => [
			val cal = Calendar.instance
			padding = new Insets(4)
			add(new Label("From"), 0, 0)
			add(new DatePicker(LocalDate.ofYearDay(cal.get(Calendar.YEAR), 1)), 1, 0)
			add(new Label("To"), 0, 1)
			add(new DatePicker(LocalDate.ofYearDay(cal.get(Calendar.YEAR), cal.get(Calendar.DAY_OF_YEAR) - 1)), 1, 1)
		]
	}

	static class ToggleButtonPeriod extends ToggleButton {

		new(TimeframePicker picker, Period period, String text) {
			super(text)
			toggleGroup = picker.group
			userData = period
		}

	}

}
