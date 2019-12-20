# Ansible_Install_Prechek
Check all nodes meet requirements for OpenShift and CPD installation

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
| |Check |	Fix |
|----------------------------------------------|----------|----------
|**OpenShift Validation** |
|OS Distribution	| X | | 	
|OS Version | X |	| 	
|Processor type | X |
|SSE 4.2 Instruction Supported | X | 	|
|Kernel Semaphore Parameter | X | X |
|Kernel Virtual Memory Parameter | X | X |
|Pre-existing Cron Job | X | 	 |
|SeLinux enforcing | X | X |
|Clock Sync | X |	X	|
|Firewall disabled	| X | X	|
|Hostname in Lowercase Characters | X |	 	|
|Size of Root Partition | X |  |
|Disk Latency | X | |
|Disk Throughput | X | |
|Docker Folder Defined	| X | - |
|Container Storage Size | X | |
|XFS FTYPE for Overlay2 Drivers | X | |
|Connectivity to IBM Artifactory Server | X | |	
|Connectivity to Redhat Artifactory Server	| X |	|
|Default Gateway | X | |
|DNS Configuration	| X | | 
|Resolving hostname via DNS | X |	|
|IPV4 IP Forwarding Set to Enable | X |	X |	
|CPU RAM Size | X | |
		
