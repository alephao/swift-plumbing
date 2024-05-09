fmt:
	swift-format format -i -r -p Sources Package.swift

lint:
	swift-format lint -r -p Sources Package.swift

.PHONY: fmt \
	lint
