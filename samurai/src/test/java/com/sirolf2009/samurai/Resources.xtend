package com.sirolf2009.samurai

import java.io.File

class Resources {
	
	val Class<?> testClass
	
	new(Class<?> testClass) {
		this.testClass = testClass;
	}
	
	def File getFolder() {
		return new File("src/test/resources/"+testClass.getSimpleName())
	}
	
	def File getFile(String location) {
		return new File(getFolder(), location)
	}
	
}