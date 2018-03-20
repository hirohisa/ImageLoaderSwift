NAME = "ImageLoader"
WORKSPACE = "#{NAME}.xcworkspace"

task :default do
end

def destination
  list = []
  `instruments -s devices`.each_line {|str|
    regx = 'iPhone.* \((.*)\) \[(.*)\].*(Simulator)'
    if match = str.match(/#{regx}/)
      list << {
        string: str.chomp,
        OS: $1,
        id: $2,
      }
    end
  }

  "platform=iOS Simulator,id=#{list.last[:id]}"
end

task :test do
  sh "xcodebuild test -workspace #{WORKSPACE} -scheme #{NAME} -destination \"#{destination()}\" -configuration Release ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test"
end
