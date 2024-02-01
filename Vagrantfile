Vagrant.configure("2") do |config|
  config.vm.define "jenk" do |jenk|
    jenk.vm.box_download_insecure = true
    jenk.vm.box = "ubuntu/focal64"
   	jenk.vm.network :forwarded_port, guest: 8080, host: 9000
    jenk.vm.network "forwarded_port", guest: 50000, host: 50000
    jenk.vm.network "private_network", ip: "100.0.0.7"
    jenk.vm.hostname = "jenk"
    jenk.vm.synced_folder "./serv", "/home/serv", disabled: false
	#jenk.vm.synced_folder "./jenkins_home", "/var/lib/jenkins", disabled: false
	jenk.vm.synced_folder "./conf", "/etc/security", type: "rsync",
    rsync__args: ["-r", "--include=limits.conf", "--exclude=*"]
    jenk.vm.provision "shell", path: "test.sh"
    jenk.vm.provider "virtualbox" do |v|
      v.name = "jenk"
      v.memory = 2048
      v.cpus = 2
    end
  end
end  