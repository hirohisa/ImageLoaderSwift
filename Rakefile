NAME = "ImageLoader"
WORKSPACE = "#{NAME}.xcworkspace"

task :clean do
	sh "xcodebuild -workspace #{WORKSPACE} -scheme #{NAME} clean"
end

task :test do
  sh "xcodebuild clean test -workspace #{WORKSPACE} -scheme #{NAME} -sdk iphonesimulator"
end
