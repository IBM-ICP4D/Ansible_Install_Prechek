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
|Hostname in Lowercase Characters | | X |	 	|
|Size of Root Partition | 50 Gb | X |  |
|Disk Latency | | X | |
|Disk Throughput | | X | |
|Docker Folder Defined	| | X | - |
|Container Storage Size | | X | |
|XFS FTYPE for Overlay2 Drivers | | X | |
|Connectivity to IBM Artifactory Server | | X | |	
|Connectivity to Redhat Artifactory Server	| | X |	|
|Default Gateway | | X | |
|DNS Configuration	| | X | | 
|Resolving hostname via DNS | | X |	|
|IPV4 IP Forwarding Set to Enable | | X |	X |	
|CPU RAM Size | | X | |

