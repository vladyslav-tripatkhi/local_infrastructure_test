# -*- mode: ruby -*-
# vi: set ft=ruby :

require "psych"

options = Psych.load_file("config.yml")

# vector_ip = "192.169.56.101"
# vector_hostname = "vector.example.test"

# fluentbit_ip = "192.169.56.103"
# fluentbit_hostname = "fluentbit.example.test"

Vagrant.configure("2") do |config|
  config.vm.box = options["box_vm_name"]
  
  application_options = options.dig("application")
  monitoring_options = options.dig("monitoring")

  config.vm.provision "shell", type: "shell", run: "once" do |shell|
    shell.inline = "grep -qxF \"$1 $2\" /etc/hosts ||  echo \"$1  $2\" >> /etc/hosts"
    shell.args = [monitoring_options.dig("ip"), monitoring_options.dig("hostname")]
  end

  # config.vm.provision "shell", type: "shell", run: "once" do |shell|
  #   shell.inline = "grep -qxF \"$1 $2\" /etc/hosts ||  echo \"$1  $2\" >> /etc/hosts"
  #   shell.args = [vector_ip, vector_hostname]
  # end

  config.vm.define "monitoring" do |monitoring|
    monitoring.vm.hostname = monitoring_options.dig("hostname")
    monitoring.vm.network "private_network", ip: monitoring_options.dig("ip")

    monitoring.vm.provider :virtualbox do |box|
      box.cpus = monitoring_options.dig("cpus")
      box.memory = monitoring_options.dig("memory")
    end

    monitoring.vm.provision "ansible_local" do |ansible| 
      ansible.playbook = "ansible/monitoring.yml"
      ansible.install_mode = "default"
      ansible.compatibility_mode = "2.0"
      ansible.config_file = "ansible/ansible.cfg"
  
      galaxy_role_file = "ansible/requirements.yml"
      if File.exist?(galaxy_role_file) && !Psych.load_file(galaxy_role_file, nil).equal?(nil)
        ansible.galaxy_role_file = galaxy_role_file
        ansible.galaxy_roles_path = '/home/vagrant/.ansible/roles/'
        ansible.galaxy_command = "ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path} --force"
      end      
    end
  end

  config.vm.define "log_generator", primary: true do |application|
    
    application.vm.hostname = application_options.dig("hostname")

    application.vm.network "private_network", ip: application_options.dig("ip")

    application.vm.provider :virtualbox do |box|
      box.cpus = application_options.dig("cpus")
      box.memory = application_options.dig("memory")
    end

    application.vm.provision "ansible_local" do |ansible| 
      ansible.playbook = "ansible/log_collector.yml"
      ansible.install_mode = "default"
      ansible.compatibility_mode = "2.0"
  
      galaxy_role_file = "ansible/requirements.yml"
      if File.exist?(galaxy_role_file) && !Psych.load_file(galaxy_role_file, nil).equal?(nil)
        ansible.galaxy_role_file = galaxy_role_file
        ansible.galaxy_roles_path = '/home/vagrant/.ansible/roles/'
        ansible.galaxy_command = "ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path} --force"
      end      
    end
  end
end
