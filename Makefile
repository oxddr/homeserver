PLAYBOOK_CMD=ansible-playbook playbook.yaml --diff
VAULT_PASS=--vault-password-file ansible.pass

.PHONY: run
run:
	 $(PLAYBOOK_CMD) $(VAULT_PASS)

.PHONY: tag
tag:
	 $(PLAYBOOK_CMD) $(VAULT_PASS) --tags $(tags)

.PHONY: secret
secret:
	ansible-vault edit $(VAULT_PASS) ansible/vars/vault.yaml
