# Ansible_Install_Prechek
Check all nodes meet requirements for OpenShift and CPD installation

# Setup
1. Clone the git repo
```
	git clone https://github.com/IBM-ICP4D/Ansible_Install_Prechek.git
```
2. Go to the Ansible_Install_Prechek directory 
```
	cd Ansible_Install_Prechek
```
3. Update the inventory file "hosts_openshift" according to the cluster
```
	vi hosts_openshift
```
	Example of hosts_openshift file:
```
[master]
9.62.100.* private_ip=10.87.103.68 name=master-03 type=master ansible_ssh_user=root ansible_ssh_pass=
9.62.100.* private_ip=10.87.103.123 name=master-02 type=master ansible_ssh_user=root ansible_ssh_pass=
9.62.100.* private_ip=10.87.103.121 name=master-01 type=master ansible_ssh_user=root ansible_ssh_pass=
[worker]
9.62.100.* private_ip=10.87.103.117 name=worker-01 type=worker ansible_ssh_user=root ansible_ssh_pass=
9.62.100.* private_ip=10.87.103.108 name=worker-03 type=worker ansible_ssh_user=root ansible_ssh_pass=
9.62.100.* private_ip=10.87.103.96 name=worker-02 type=worker ansible_ssh_user=root ansible_ssh_pass=
[loadbalancer]
9.62.100.* private_ip=10.87.103.66 name=loadbalancer-01 type=proxy ansible_ssh_user=root ansible_ssh_pass=
	
```

# Usage
```
This script checks if all nodes meet requirements for OpenShift and CPD installation.
Arguments: 
    --install=[ocp|cpd]                         To specify installation type
    --fix                                       To address any issue in the cluster 
    --help                                      To see help 

Example: 
./pre_install_check_v25.sh --install=ocp
./pre_install_check_v25.sh --install=ocp --fix
```

# Validation
| | Requirements | Check |	Fix |
|----------------------------------------------|----------------------------------------------|----------|----------
|**OpenShift Validation** |
|OS Distribution	| RedHat | X |   | 
|OS Version | 7.6, 7.7| X |	| 
|OS Kernel Patch | 3.10.0-957, 3.10.0-1062| X |	|
|Processor type | x86_64 | X | |
|SSE 4.2 Instruction Supported | SSE4_2 | X | 	|
|Kernel Semaphore Parameter | "kernel.sem = 250 1024000 32 4096" | X | X |
|Kernel Virtual Memory Parameter | "vm.max_map_count=262144" | X | X |
|Pre-existing Cron Job | Stop existing cron jobs | X | 	 |
|SeLinux enforcing | Enforcing | X | X |
|Clock Sync | Synchronize computer system clock on all nodes | X |	X	|
|Firewall disabled	| Firewalld needs turn off. Will turn it on later. | X | X	|
|Hostname in Lowercase Characters | Hostname must be all lowercase | X |	 	|
|Size of Root Partition | 50 Gb | X |  |
|Disk Latency | 50 Kb/Sec | X | |
|Disk Throughput | 1 Gb/5 Sec| X | |
|Docker Folder Defined	| /var/lib/docker exists | X | - |
|Docker Container Storage Size | 200 Gb | X | |
|XFS FTYPE for Overlay2 Drivers | Must be XFS type filesystem | X | |
|Connectivity to IBM Artifactory Server | Not mandatory| X | |	
|Connectivity to Redhat Artifactory Server	| registry.redhat.io | X |	|
|Default Gateway | Route for default gateway exists | X | |
|DNS Configuration	| DNS must be enabled | X | | 
|Resolving hostname via DNS | Hostname resolution enabledn| X |	|
|IPV4 IP Forwarding Set to Enable | | X |	X |	
|CPU RAM Size | | X | |

