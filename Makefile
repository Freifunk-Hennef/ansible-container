ANSIBLE=ansible-playbook

all:
	$(ANSIBLE) -i ./hosts ./playbooks/site.yml -t setup,start

start:
	$(ANSIBLE) -i ./hosts ./playbooks/site.yml -t start

setup:
	$(ANSIBLE) -i ./hosts ./playbooks/site.yml -t setup

