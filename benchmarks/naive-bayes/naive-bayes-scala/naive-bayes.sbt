name := "naive-bayes"

version := "1.0"

scalaVersion := "2.11.8"

libraryDependencies += "org.apache.spark"     %% "spark-core"    % "1.6.1"
libraryDependencies += "org.apache.spark"     %% "spark-mllib"   % "1.6.1"
libraryDependencies += "org.apache.accumulo"  %  "accumulo-core" % "1.7.1"
libraryDependencies += "org.apache.zookeeper" %  "zookeeper"     % "3.4.6"
libraryDependencies += "org.apache.hadoop"    %  "hadoop-client" % "2.7.1"

unmanagedJars in Compile += file("../util/target/scala-2.11/util_2.11-1.0.jar")

mergeStrategy in assembly <<= (mergeStrategy in assembly) {
  (old) => {
    case PathList("META-INF", xs @ _*) => MergeStrategy.discard
    case "reference.conf" => MergeStrategy.concat
    case "application.conf" => MergeStrategy.concat
    case "META-INF/MANIFEST.MF" => MergeStrategy.discard
    case "META-INF\\MANIFEST.MF" => MergeStrategy.discard
    case _ => MergeStrategy.first
  }
}
