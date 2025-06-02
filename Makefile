format:
	@swift-format format --in-place --parallel --recursive Sources/ Tests/
	@echo "Swift code formatted successfully."

lint:
	@swift-format lint --strict --parallel --recursive Sources/ Tests/
	@echo "Swift code linted successfully."

test:
	@swift test
	@echo "Swift tests passed successfully."

.PHONY: format lint test
