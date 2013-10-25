// Comment to get more information during initialization
//logLevel := Level.Warn

// The Typesafe repository 
resolvers += "Typesafe repository" at "http://repo.typesafe.com/typesafe/releases/"

resolvers += "Maven" at "http://repo1.maven.org/maven2/"

resolvers += Classpaths.typesafeResolver

resolvers += "scct-github-repository" at "http://mtkopone.github.com/scct/maven-repo"

resolvers += "jgit-repo" at "http://download.eclipse.org/jgit/maven"


// Use the Play sbt plugin for Play projects
addSbtPlugin("play" % "sbt-plugin" % "2.1.3")

addSbtPlugin("org.ensime" % "ensime-sbt-cmd" % "0.0.10")

addSbtPlugin("reaktor" % "sbt-scct" % "0.2-SNAPSHOT")

addSbtPlugin("io.spray" % "sbt-revolver" % "0.7.0")

addSbtPlugin("com.typesafe.sbt" % "sbt-git" % "0.6.2")

addSbtPlugin("com.orrsella" % "sbt-sublime" % "1.0.9")

//addSbtPlugin("net.litola" % "play-sass" % "0.1.2" from "http://deity.mintengine.com/play-sass-0.1.2.jar")
