.PHONY: run
run:
	ansible-playbook ansible/playbook.yaml --diff --ask-become-pass

.PHONY: tag
tag:
	ansible-playbook ansible/playbook.yaml --diff --tags $(tags)
