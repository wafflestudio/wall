import sbt._
import Keys._
import PlayProject._

object ApplicationBuild extends Build {

	val appName = "Infinite Wall"
	val appVersion = "1.0-M1"

	val appDependencies = Seq(
		// Add your project dependencies here,
		"postgresql" % "postgresql" % "8.4-701.jdbc4",
		"ru.circumflex" % "circumflex-markeven" % "2.0",
		/*"com.typesafe" %% "play-plugins-mailer" % "2.0.2",*/
		"org.apache.commons" % "commons-email" % "1.2",
		"org.mindrot" % "jbcrypt" % "0.3m")

	val main = PlayProject(appName, appVersion, appDependencies, mainLang = SCALA).settings(
		coffeescriptOptions := Seq("native", "coffee -p")
		// Add your own project settings here
		)

}
