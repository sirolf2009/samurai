package com.sirolf2009.samurai

import com.sirolf2009.samurai.annotations.Register
import com.sirolf2009.samurai.strategy.IStrategy
import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.reflections.Reflections
import org.reflections.scanners.SubTypesScanner
import org.reflections.scanners.TypeAnnotationsScanner
import com.sirolf2009.samurai.dataprovider.DataProvider
import com.sirolf2009.samurai.optimizer.IOptimizer

class Registered {

	@Accessors static val List<Registration<IStrategy>> strategies = new ArrayList()
	@Accessors static val List<Registration<DataProvider>> dataProviders = new ArrayList()
	@Accessors static val List<Registration<IOptimizer>> optimizers = new ArrayList()

	def static runRegistration() {
		val reflections = new Reflections("", new SubTypesScanner(), new TypeAnnotationsScanner())
		val registeredClasses = reflections.getTypesAnnotatedWith(Register)
		
		strategies.clear()
		registeredClasses.filter[interfaces.findFirst[IStrategy.isAssignableFrom(it)] != null].forEach [
			val annotation = (annotations.findFirst[annotationType == Register] as Register)
			strategies.add(new Registration<IStrategy>(it as Class<? extends IStrategy>, annotation.name, annotation.type))
		]
		
		dataProviders.clear()
		registeredClasses.filter[DataProvider.isAssignableFrom(it)].forEach [
			val annotation = (annotations.findFirst[annotationType == Register] as Register)
			dataProviders.add(new Registration<DataProvider>(it as Class<? extends DataProvider>, annotation.name, annotation.type))
		]
		
		optimizers.clear()
		registeredClasses.filter[interfaces.findFirst[IOptimizer.isAssignableFrom(it)] != null].forEach [
			val annotation = (annotations.findFirst[annotationType == Register] as Register)
			optimizers.add(new Registration<IOptimizer>(it as Class<? extends IOptimizer>, annotation.name, annotation.type))
		]
	}
	
	@Data public static class Registration<E> {
		
		Class<? extends E> clazz
		String name
		String type
		
		override toString() {
			return name
		}
		
	}

}
