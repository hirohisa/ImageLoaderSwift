NAME = "ImageLoader"
WORKSPACE = "#{NAME}.xcworkspace"
DESTINATION = "platform=iOS Simulator,OS=10.1,name=iPhone 7"

task :default do
  sh "bundle install --path vendor/bundle/"
  sh "bundle exec pod install"
end

task :test do
  sh "bundle install --path vendor/bundle/"
  sh "bundle exec pod install"
  sh "xcodebuild test -workspace #{WORKSPACE} -scheme #{NAME} -destination \"#{DESTINATION}\" -configuration Release ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=YES test | xcpretty"
end
