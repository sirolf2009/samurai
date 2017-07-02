package com.sirolf2009.samurai.gui.picker

import com.sirolf2009.samurai.Samurai
import java.time.Duration
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.ZonedDateTime
import java.util.Calendar
import javafx.beans.InvalidationListener
import javafx.beans.property.BooleanProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.geometry.Insets
import javafx.geometry.Orientation
import javafx.geometry.Pos
import javafx.scene.control.DatePicker
import javafx.scene.control.Label
import javafx.scene.control.Separator
import javafx.scene.control.TitledPane
import javafx.scene.control.ToggleButton
import javafx.scene.control.ToggleGroup
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.layout.GridPane
import javafx.scene.layout.HBox
import javafx.scene.layout.VBox
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data

class PickerTimeframe extends TitledPane {

	@Accessors var BooleanProperty satisfiedProperty = new SimpleBooleanProperty(this, "satisfied", false)
	@Accessors var SimpleObjectProperty<Timeframe> timeframeProperty = new SimpleObjectProperty<Timeframe>(this, "timeframe")
	@Accessors var SimpleObjectProperty<Duration> periodProperty = new SimpleObjectProperty<Duration>(this, "period")
	@Accessors var SimpleObjectProperty<ZonedDateTime> fromProperty = new SimpleObjectProperty<ZonedDateTime>(this, "from")
	@Accessors var SimpleObjectProperty<ZonedDateTime> toProperty = new SimpleObjectProperty<ZonedDateTime>(this, "to")
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
			add(new DatePicker(LocalDate.ofYearDay(cal.get(Calendar.YEAR)-20, 1)) => [
				onAction = [fromProperty.set(ZonedDateTime.ofInstant(Instant.ofEpochSecond((source as DatePicker).value.atStartOfDay(ZoneId.systemDefault).toEpochSecond(), 0), ZoneId.systemDefault))]
			], 1, 0)
			add(new Label("To"), 0, 1)
			add(new DatePicker(LocalDate.ofYearDay(cal.get(Calendar.YEAR), cal.get(Calendar.DAY_OF_YEAR) - 1)) => [
				onAction = [toProperty.set(ZonedDateTime.ofInstant(Instant.ofEpochSecond((source as DatePicker).value.atStartOfDay(ZoneId.systemDefault).toEpochSecond(), 0), ZoneId.systemDefault))]
			], 1, 1)

			fromProperty.set(ZonedDateTime.of(cal.get(Calendar.YEAR) - 20, 1, 1, 1, 0, 0, 0, ZoneId.systemDefault))
			toProperty.set(ZonedDateTime.of(cal.get(Calendar.YEAR), 1, 1, 1, 0, 0, 0, ZoneId.systemDefault))
		]
		root.children += new Separator(Orientation.HORIZONTAL)
		root.children += new HBox(4, new Label("Period"), new HBox(
			new ToggleButtonPeriod(this, Duration.ofMinutes(1), "1"),
			new ToggleButtonPeriod(this, Duration.ofMinutes(3), "3"),
			new ToggleButtonPeriod(this, Duration.ofMinutes(15), "15"),
			new ToggleButtonPeriod(this, Duration.ofMinutes(30), "30"),
			new ToggleButtonPeriod(this, Duration.ofHours(1), "1h"),
			new ToggleButtonPeriod(this, Duration.ofHours(4), "4h"),
			new ToggleButtonPeriod(this, Duration.ofDays(1), "1d")
		) => [
			alignment = Pos.CENTER
		])
		group.selectedToggleProperty.addListener [ observable, old, newToggle |
			if(newToggle === null) {
				periodProperty.set(null)
				graphic = null
				satisfiedProperty.set(false)
			} else {
				periodProperty.set(group.selectedToggle.userData as Duration)
				graphic = new ImageView(new Image(Samurai.getResourceAsStream("/ok.png")))
				satisfiedProperty.set(true)
			}
		]
		
		val InvalidationListener objectUpdater = [
			if(periodProperty.get !== null && fromProperty.get !== null && toProperty.get !== null) {
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

		new(PickerTimeframe picker, Duration period, String text) {
			super(text)
			toggleGroup = picker.group
			userData = period
		}

	}
	
	@Data public static class Timeframe {
		
		Duration period
		ZonedDateTime from
		ZonedDateTime to
			
	}

}
