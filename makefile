TERRAFORM := terraform
INFRA_DIR :=infrastructure

tf_init1:
	@echo "Initializing Terraform in $(INFRA_DIR)..."
	cd $(INFRA_DIR) && $(TERRAFORM) init -upgrade


tf_init:
	cd infrastructure && terraform init -upgrade

tf_plan:
	cd infrastructure && terraform plan

tf_apply:
	cd infrastructure && terraform apply -auto-approve

tf_destroy:
	cd infrastructure && terraform destroy -auto-approve

yc_list_images:
	yc compute image list --folder-id standard-images > images.txt