require 'buildr/scala'

# Generated by Buildr 1.3.4, change to your liking
# Version number for this release
VERSION_NUMBER = "1.0.0"
# Group identifier for your projects
GROUP = "scala-plugin"
COPYRIGHT = "(c) Adam Warski 2009"

# Dependencies
JSR305 = "com.google.code.findbugs:jsr305:jar:1.3.9"

# Specify Maven 2.0 remote repositories here, like this:
repositories.remote << "http://www.ibiblio.org/maven2/"

desc "The Scala-plugin project"
define "scala-plugin" do

  project.version = VERSION_NUMBER
  project.group = GROUP
  manifest["Implementation-Vendor"] = COPYRIGHT

  define "plugin" do
    compile.with JSR305
    package(:jar)
  end

  define "example" do
    test.with JSR305
    test do
        # First packaging the app
        project("plugin").task("package").invoke()

        # Then getting the full path to the package
        packageName = project("plugin").packages.first.to_s

        # The path to the test files
        basePluginTestPath = project.path_to(:source, :test, :scala)

        # The path where compiled classes can be written
        targetPath = project.path_to(:target, :test, :classes)

        # Finally, we also need to the path to the JSR305 jar
        jsr305dep = project("example").task("test").dependencies.to_a.select { |dep| dep.respond_to?("to_spec") && dep.to_spec =~ /jsr305/ }.first

        # And invoking scala
        checkResults({
            #"scalac -Xplugin:#{packageName} #{basePluginTestPath}/Example0.scala" => "definitely division by zero",
            "scalac -d #{targetPath} -cp #{jsr305dep} -Xplugin:#{packageName} #{basePluginTestPath}/Example1.scala" => "",
        })
    end
  end

end

def checkResults(commandsToResults)
    commandsToResults.keys.each do |command|
        puts "Checking the result for command '#{command}'..."

        result = `#{command} 2>&1`
        puts result
        #if !result.include? commandsToResults[command]
        #    fail "Command '#{command}' result should contain:\n#{commandsToResults[command]}\nbut was:\n#{result}"
        #end
    end
end