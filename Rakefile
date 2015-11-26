NAME = "ImageLoader"
WORKSPACE = "#{NAME}.xcworkspace"

task :test do
  sh "carthage bootstrap"
  sh "xcodebuild clean -workspace #{WORKSPACE} -scheme #{NAME} -sdk iphonesimulator build test | xcpretty -c"
end
