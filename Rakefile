NAME = "ImageLoader"
WORKSPACE = "#{NAME}.xcworkspace"
SDK = "iphonesimulator"
DESTINATION = "platform=iOS Simulator,name=iPhone 6,OS=9.3"

task :test do
  sh "carthage bootstrap --platform iOS"
  sh "xcodebuild clean -workspace #{WORKSPACE} -scheme #{NAME} -sdk #{SDK} -destination \"#{DESTINATION}\" build test | xcpretty -c"
end
