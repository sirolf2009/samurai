package com.sirolf2009.samurai.annotations

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target

/**
 * Register a class to be used in the framework. Its superclass/interfaces determine where and when it will be used. 
 * Classes annotated with this annotation must always have an empty constructor
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
annotation Register {
	
	String name
	String type
	
}
