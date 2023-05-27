VAULT_PASS=--vault-password-file ansible.pass

.PHONY: run
run:
	ansible-playbook ansible/playbook.yaml --diff $(VAULT_PASS)

.PHONY: tag
tag:
	ansible-playbook ansible/playbook.yaml --diff $(VAULT_PASS) --tags $(tags)

.PHONY: secret
secret:
	ansible-vault edit $(VAULT_PASS) ansible/vars/vault.yaml
