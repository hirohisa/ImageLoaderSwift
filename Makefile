NAME = ImageLoader
WORKSPACE = $(NAME).xcworkspace

clean:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(NAME) \
		clean

test:
	xcodebuild \
		-workspace $(WORKSPACE) \
		-scheme $(NAME)

