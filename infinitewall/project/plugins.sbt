// Comment to get more information during initialization
//logLevel := Level.Warn

// The Typesafe repository 
resolvers += "Typesafe repository" at "http://repo.typesafe.com/typesafe/releases/"

resolvers += Classpaths.typesafeResolver

resolvers += "Maven" at "http://repo1.maven.org/maven2/"

resolvers += Classpaths.typesafeResolver

resolvers += "scct-github-repository" at "http://mtkopone.github.com/scct/maven-repo"

resolvers += "jgit-repo" at "http://download.eclipse.org/jgit/maven"


// Use the Play sbt plugin for Play projects
addSbtPlugin("com.typesafe.play" % "sbt-plugin" % "2.2.0")

addSbtPlugin("org.ensime" % "ensime-sbt-cmd" % "0.1.2")

// not compatible with scala 2.10 + sbt 0.13
//addSbtPlugin("reaktor" % "scct" % "0.2-SNAPSHOT")

addSbtPlugin("com.typesafe.sbt" % "sbt-git" % "0.6.2")

//addSbtPlugin("net.litola" % "play-sass" % "0.1.2" from "http://deity.mintengine.com/play-sass-0.1.2.jar")
