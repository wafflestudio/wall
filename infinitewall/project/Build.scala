import sbt._
import Keys._
import play.Project._

object ApplicationBuild extends Build {

	val appName = "InfiniteWall"
	val appVersion = "1.0-M1"

	val appDependencies = Seq(
		jdbc, anorm, filters,
		// Add your project dependencies here,
		"postgresql" % "postgresql" % "8.4-701.jdbc4",
		"ru.circumflex" % "circumflex-markeven" % "2.0",
		/*"com.typesafe" %% "play-plugins-mailer" % "2.0.2",*/
		"commons-lang" % "commons-lang" % "2.6",
		"org.apache.commons" % "commons-email" % "1.2",
    "com.github.theon" %% "scala-uri" % "0.3.2",
		"org.mindrot" % "jbcrypt" % "0.3m")

	val main = play.Project(appName, appVersion, appDependencies).settings(
		coffeescriptOptions := Seq("native", "coffee -p")
		// Add your own project settings here
		)

}
