package com.sirolf2009.samurai.gui

import org.controlsfx.control.StatusBar
import javafx.scene.control.Button
import javafx.concurrent.Task
import org.controlsfx.control.TaskProgressView
import org.controlsfx.control.PopOver

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
	}

	def void setTask(Task<?> task) {
		taskList.tasks.add(task)
		this.task = task
		this.textProperty.bind(task.messageProperty)
		this.progressProperty.bind(task.progressProperty)
	}

}
