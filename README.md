# Ansible_Install_Prechek
Check all nodes meet requirements for OpenShift and CPD installation

# Usage
```
./pre_install_check_v25.sh
This script checks if all nodes meet requirements for OpenShift and CPD installation.
Arguments: 
--install=[ocp|cpd]                         To specify installation type
--installpath=[installation file location]  To specify installation directory
--ocuser=[openshift user]                   To specify Openshift user used for installation
--ocpassword=[password]                     To specify password for Openshift user
                                            Set OCPASSWORD environment variable to avoid --ocpassword command line argument
--fix                                       To address any issue in the cluster 
--help                                      To see help 

Example: 
./pre_install_check_v25.sh --install=cpd --installpath=/ibm/cpd --ocuser=ocadmin
./pre_install_check_v25.sh --install=cpd --installpath=/ibm/cpd --ocuser=ocadmin --ocpassword=icp4dAdmin
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
|Default Gateway || |
|DNS Configuration	|| | 
|Resolving hostname via DNS ||	|
|IPV4 IP Forwarding Set to Enable ||	|	
|CPU RAM Size || |
		
