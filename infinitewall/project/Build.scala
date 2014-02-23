import sbt._
import Keys._
import play.Project._
//import spray.revolver.RevolverPlugin._

object ApplicationBuild extends Build {

	val appName = "InfiniteWall"
	val appVersion = "1.0-M1"

	val appDependencies = Seq(
			jdbc, /*anorm,*/ filters,
			// Add your project dependencies here,
			"postgresql" % "postgresql" % "9.1-901.jdbc4",
			"ru.circumflex" % "circumflex-markeven" % "2.1",
			"commons-lang" % "commons-lang" % "2.6",
			"org.apache.commons" % "commons-email" % "1.2",
            "com.typesafe" %% "play-plugins-mailer" % "2.2.0",
			"commons-codec" % "commons-codec" % "1.6",
			"com.github.theon" %% "scala-uri" % "0.3.6",
			"net.fwbrasil" % "activate-core_2.10" % "1.4.4",  //exclude("org.scala-stm", "scala-stm_2.10.0"),
			"net.fwbrasil" % "activate-play_2.10" % "1.4.4",  //exclude("org.scala-stm", "scala-stm_2.10.0"),
			"net.fwbrasil" % "activate-jdbc_2.10" % "1.4.4",  //exclude("org.scala-stm", "scala-stm_2.10.0"),
			"com.clever-age" % "play2-elasticsearch" % "0.8-SNAPSHOT",  //exclude("org.scala-stm", "scala-stm_2.10.0"),
			"ws.securesocial" % "securesocial_2.10" % "2.1.3"  exclude("org.scala-stm", "scala-stm_2.10.0"),
			"org.mindrot" % "jbcrypt" % "0.3m",
			"org.apache.tika" % "tika-bundle" % "1.2",
			"se.digiplant" %% "play-scalr" % "1.0.1",
            "org.webjars" %% "webjars-play" % "2.2.1-2",
            "org.webjars" % "requirejs" % "2.1.1",
            "org.webjars" % "angularjs" % "1.2.13"
			)

	val main = play.Project(appName, appVersion, appDependencies).settings(
			// Add your own project settings here
			resolvers += Resolver.url("play-plugin-releases", new URL("http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/"))(Resolver.ivyStylePatterns),
			resolvers += Resolver.url("play-plugin-frozens", new URL("http://repo.scala-sbt.org/scalasbt/sbt-plugin-frozens/"))(Resolver.ivyStylePatterns),
			resolvers += Resolver.url("sbt-plugin-snapshots", new URL("http://repo.scala-sbt.org/scalasbt/sbt-plugin-snapshots/"))(Resolver.ivyStylePatterns),
			resolvers += Resolver.url("sbt-plugin-releases", new URL("http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/"))(Resolver.ivyStylePatterns),
			resolvers += "OSS Sonatype Snapshots" at "http://oss.sonatype.org/content/repositories/snapshots/",
			coffeescriptOptions := Seq("native", "coffee -p"),
            scalaVersion := "2.10.3",
			scalacOptions ++= Seq("-feature","-language:postfixOps","-language:implicitConversions", "-language:reflectiveCalls")
			).settings(com.typesafe.sbt.SbtScalariform.scalariformSettings: _*
            ).settings(play.Project.playScalaSettings: _*)
			/*.settings(
				ScctPlugin.instrumentSettings : _*
			).settings(parallelExecution in ScctPlugin.ScctTest := false
			).settings(Revolver.settings: _*)*/

			templatesImport ++= Seq(
				"se.digiplant._"
			)
}
