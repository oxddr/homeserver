.PHONY: run
run:
	ansible-playbook playbook.yaml --diff --ask-become-pass

.PHONY: tag
tag:
	ansible-playbook playbook.yaml --diff --tags $(tags)
