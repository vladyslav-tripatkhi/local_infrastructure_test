# Usage:
# ToDo: add usage instructions

# .DEFAULT_GOAL := generate
.PHONY: all say_hello generate clean
.SILENT: base_box_build base_box_cleanup python_virtualenv_setup python_virtualenv_cleanup render_template

PYTHON_BIN=python3

PROVIDER := virtualbox
BASE_BOX_VM_NAME := ubuntu_18.04_base
BASE_BOX_FILE_NAME := ${BASE_BOX_VM_NAME}.box

APPLICATIONS := all
APPLICATIONS_TO_PROVISION := ${APPLICATIONS}

APPLICATION_VM_HOSTNAME=log_generator.example.test
APPLICATION_VM_CPUS=2
APPLICATION_VM_MEMORY=2048

MONITORING_VM_HOSTNAME=monitoring.example.test
MONITORING_VM_CPUS=2
MONITORING_VM_MEMORY=6144


all:
	echo "DUMMY"

launch: python_virtualenv_setup base_box_build render_template vagrant_launch

python_virtualenv_setup:
	python -m virtualenv -p ${PYTHON_BIN} virtualenv; \
	source virtualenv/bin/activate; \
	pip install -r requirements.txt; \
	echo "Python virtualenv has been installed successfully."; \
	echo "To use it, type 'source virtualenv/bin/activate' in your console."

python_virtualenv_cleanup:
	rm -rf virtualenv; \
	find . -name '*.pyc' -delete; \
	echo "Python virtualenv has been removed successfully."

base_box_build:
	cd base; \
	vagrant up --destroy-on-error --provider ${PROVIDER}; \
	vagrant package --output ${BASE_BOX_FILE_NAME}; \
	vagrant box add ${BASE_BOX_VM_NAME} ${BASE_BOX_FILE_NAME}; \
	vagrant destroy -f;

base_box_cleanup:
	cd base; \
	rm -rf ${BASE_BOX_FILE_NAME}; \
	vagrant box remove ${BASE_BOX_VM_NAME};

render_template:
	sed \
		-e "s/BASE_BOX_VM_NAME/\"${BASE_BOX_VM_NAME}\"/g" \
		-e "s/APPLICATION_VM_HOSTNAME/\"${APPLICATION_VM_HOSTNAME}\"/g" \
		-e "s/APPLICATION_VM_CPUS/${APPLICATION_VM_CPUS}/g" \
		-e "s/APPLICATION_VM_MEMORY/${APPLICATION_VM_MEMORY}/g" \
		-e "s/MONITORING_VM_HOSTNAME/\"${MONITORING_VM_HOSTNAME}\"/g" \
		-e "s/MONITORING_VM_CPUS/${MONITORING_VM_CPUS}/g" \
		-e "s/MONITORING_VM_MEMORY/${MONITORING_VM_MEMORY}/g" \
	config.yml.template > config.yml

vagrant_launch:
	echo "vagrant up"

vagrant_destroy:
	echo "vagrant destroy -f"

generate:
	@echo "Creating empty text files"
	touch file-{1..10}.txt

clean:
	@echo "Cleaning up"
	rm file-{1..10}.txt
