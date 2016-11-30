package com.sirolf2009.samurai.gui

import javafx.animation.Animation
import javafx.animation.KeyFrame
import javafx.animation.Timeline
import javafx.application.Platform
import javafx.concurrent.Task
import javafx.scene.control.Button
import javafx.scene.control.ProgressBar
import javafx.util.Duration
import org.controlsfx.control.PopOver
import org.controlsfx.control.StatusBar
import org.controlsfx.control.TaskProgressView

import static com.sirolf2009.samurai.util.GUIUtil.*
import javafx.scene.layout.StackPane
import javafx.scene.control.Label

class SamuraiStatusBar extends StatusBar {

	val TaskProgressView<Task<?>> taskList = new TaskProgressView()
	var Task<?> task

	new() {
		rightItems += new Button("^") => [
			onAction = [
				new PopOver(taskList).show(this)
			]
		]
		rightItems += new Button("Cancel") => [
			onAction = [task?.cancel()]
		]
		leftItems += new StackPane(new ProgressBar(0) => [freeMemory|
			freeMemory.setStyle("-fx-accent: green;");
			val runtime = Runtime.runtime
			val timer = new Timeline(new KeyFrame(Duration.millis(1000), [
				val totalMemory = runtime.totalMemory as double
				val usedMemory = totalMemory - runtime.freeMemory as double
				val usedMemoryPercentage = usedMemory/totalMemory
				freeMemory.progress = usedMemoryPercentage
			]))
			timer.cycleCount = Animation.INDEFINITE
			timer.play()
		], new Label("Memory"))
	}

	def void setTask(Task<?> task) {
		Platform.runLater [
			taskList.tasks.add(task)
			this.task = task
			this.textProperty.bind(task.messageProperty)
			this.progressProperty.bind(task.progressProperty)
			task.onFailed = showErrorDialog
		]
	}

	def void addTask(Task<?> task) {
		Platform.runLater [
			taskList.tasks.add(task)
		]
	}

}
