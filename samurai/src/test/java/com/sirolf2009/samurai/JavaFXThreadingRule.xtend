package com.sirolf2009.samurai

import java.time.Duration
import java.util.concurrent.CountDownLatch
import javafx.application.Platform
import javafx.embed.swing.JFXPanel
import javax.swing.SwingUtilities
import org.apache.logging.log4j.LogManager
import org.junit.rules.TestRule
import org.junit.runner.Description
import org.junit.runners.model.Statement

class JavaFXThreadingRule implements TestRule {

	static val log = LogManager.logger
	static var boolean jfxIsSetup

	override apply(Statement base, Description description) {
		return new OnJFXThreadStatement(base)
	}

	private static class OnJFXThreadStatement extends Statement {

		val Statement statement
		var Throwable exception

		new(Statement statement) {
			this.statement = statement
		}

		override evaluate() throws Throwable {
			if(!jfxIsSetup) {
				setupJavaFX()
				jfxIsSetup = true
			}
			val countDownLatch = new CountDownLatch(1)

			Platform.runLater [
				try {
					statement.evaluate()
				} catch(Exception e) {
					exception = e
				}
				countDownLatch.countDown()
			]
			countDownLatch.await()

			if(exception !== null) {
				throw exception
			}
		}

		def setupJavaFX() {
			val start = System.currentTimeMillis
			val latch = new CountDownLatch(1)
			SwingUtilities.invokeLater [
				new JFXPanel()
				latch.countDown()
			]
			log.info("Initializing javaFX")
			latch.await()
			log.info("Initialized javaFX in " + Duration.ofMillis(System.currentTimeMillis - start))
		}

	}

}
