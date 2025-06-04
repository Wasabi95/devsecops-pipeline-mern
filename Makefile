# app/Makefile - Single-command automation
.PHONY: build up down test deploy-infra destroy-infra provision clean setup-dev security-scan init-infra

# Docker Operations
build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

# Testing
test:
	@echo "Running tests..."
	cd client && npm test
	cd server && npm test

# Infrastructure Automation
# Fucking safety first
CONFIRM_DESTROY := @echo -n "Are you fucking sure? (y/n) " && read ans && [ $${ans:-N} = y ]

# Terraform Operations

# New target to initialize Terraform providers
init-infra:
	@echo "Initializing fucking Terraform modules..."
	cd terraform-iac && terraform init -upgrade -reconfigure

validate-infra: init-infra # Now validate depends on init
	@echo "Validating fucking Terraform..."
	cd terraform-iac && terraform validate

deploy-infra: validate-infra
	@echo "Generating fucking execution plan..."
	cd terraform-iac && terraform plan -out=tfplan
	${CONFIRM_DESTROY}
	cd terraform-iac && terraform apply -auto-approve tfplan

destroy-infra:
	@echo "Planning fucking destruction..."
	cd terraform-iac && terraform plan -destroy -out=destroy_plan
	@echo "☠️☠️☠️ DESTRUCTION IMMINENT ☠️☠️☠️"
	${CONFIRM_DESTROY}
	cd terraform-iac && terraform apply -auto-approve destroy_plan
	@echo "Purging fucking state files..."
	rm -f terraform-iac/*.tfstate* terraform-iac/.terraform.lock.hcl

nuke-infra:
	@echo "☢️☢️☢️ NUKE PROTOCOL ENGAGED ☢️☢️☢️"
	${CONFIRM_DESTROY}
	@echo "Checking for Terraform state lock..."
	@LOCK_ID=$$(cd terraform-iac && terraform show -no-color 2>&1 | grep -oP '(?<=Lock Info:\s+ID:\s+)\S*') ; \
	if [ -n "$$LOCK_ID" ]; then \
		echo "Forcibly unlocking state with LOCK_ID=$$LOCK_ID..."; \
		cd terraform-iac && terraform force-unlock -force $$LOCK_ID; \
	else \
		echo "No lock detected, skipping force-unlock."; \
	fi
	@echo "Executing destruction sequence..."
	cd terraform-iac && terraform destroy -auto-approve -refresh=false
	@echo "Incinerating state files..."
	rm -rf terraform-iac/.terraform* terraform-iac/*.tfstate*
	@echo "☢️☢️☢️ NUKE COMPLETE ☢️☢️☢️"



provision:
	@echo "Provisioning with Ansible..."
	ansible-playbook -i ansible/hosts ansible/playbook.yml

# Utility Commands
clean:
	docker system prune -f
	rm -rf client/node_modules server/node_modules

# Environment Setup
setup-dev: build up
	@echo "Dev environment ready at http://localhost:3000"

# Security Scanning
security-scan:
	@echo "Running Trivy scan..."
	docker run --rm -v $(PWD):/src aquasec/trivy fs /src
	@echo "Running Checkov scan on Terraform..."
	cd terraform-iac && checkov -d .