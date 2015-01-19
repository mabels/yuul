package com.adviser.yuul.bouncer

import org.yaml.snakeyaml.Yaml
import java.io.FileInputStream
import java.io.File
import java.util.Map

class Service {
	var stopped = false
	

	def start() {

		val yaml = new Yaml()
		val input = new FileInputStream(new File("yuul.yam"))
		val Map<String, Object> yuul = yaml.load(input) as Map<String, Object>
		
		

		new Thread(
			new Runnable() {

				override run() {
					while(stopped) {

						Thread.sleep(10000);
					}
				}

			})
	}
}
