.PHONY: help venv install lint ci-lint release dry-run setup setup-unbound

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

venv: ## Create local virtualenv and install Python dependencies
	python3 -m venv venv
	venv/bin/pip install --upgrade pip
	venv/bin/pip install -r requirements.txt

install: venv ## Install Python dependencies and Ansible roles
	venv/bin/pip install -r requirements.txt
	venv/bin/ansible-galaxy install -r requirements.yml --roles-path ./roles

lint: venv ## Run ansible-lint (in venv)
	venv/bin/ansible-lint

ci-lint: install ## Run full lint pipeline in venv (galaxy + ansible-lint + yamllint)
	venv/bin/ansible-lint
	venv/bin/yamllint .

release: ## Create a new release (requires semantic-release)
	npx semantic-release

dry-run: ## Preview what semantic-release would do
	npx semantic-release --dry-run
