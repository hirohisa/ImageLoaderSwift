NAME = ImageLoader
WORKSPACE = $(NAME).xcworkspace

clean:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(NAME) \
		clean

test:
	xcodebuild \
		clean test \
		-workspace $(WORKSPACE) \
		-scheme $(NAME) test \
		-sdk iphonesimulator \
		-configuration Debug \
		OBJROOT=build \
		TEST_AFTER_BUILD=YES \
		GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES \
		GCC_GENERATE_TEST_COVERAGE_FILES=YES

send-coverage:
	coveralls \
		-e ImageLoaderTests