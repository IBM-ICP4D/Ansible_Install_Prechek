#!/bin/bash

#setup output file
OUTPUT="/tmp/preInstallCheckResult"
ANSIBLEOUT="/tmp/preInstallAnsible"

rm -f ${OUTPUT}
rm -f ${ANSIBLEOUT}

function usage(){
    echo "This script checks if all nodes meet requirements for OpenShift and CPD installation."
    echo "Arguments: "
    echo "--install=[ocp|cpd]                         To specify installation type"
    echo "--installpath=[installation file location]  To specify installation directory"
    echo "--ocuser=[openshift user]                   To specify Openshift user used for installation"
    echo "--ocpassword=[password]                     To specify password for Openshift user"
    echo "                                            Set OCPASSWORD environment variable to avoid --ocpassword command line argument"
    echo "--fix                                       To address any issue in the cluster "
    echo "--help                                      To see help "
    echo ""
    echo "Example: "
    echo "./pre_install_check_v25.sh --install=cpd --installpath=/ibm/cpd --ocuser=ocadmin"
    echo "./pre_install_check_v25.sh --install=cpd --installpath=/ibm/cpd --ocuser=ocadmin --ocpassword=icp4dAdmin"
    echo "./pre_install_check_v25.sh --install=ocp"
    echo "./pre_install_check_v25.sh --install=ocp --fix"
}

function helper(){
    echo "##########################################################################################
   Help:
    ./$(basename $0) --install=[ocp|cpd] --installpath=[installation file location]
                     --ocuser=[openshift user] --ocpassword=[password]

    Specify install type, installation directory, Openshift user and password to start the validation.
    Run it without "--fix" option to find out any issue on the cluster. 
    Next run with  "--fix" optiom to address issues on the cluster.
    Use this pre install check before Cloud Pak for Data installation.
##########################################################################################"
}

function printout() {
    echo -e "$1" | tee -a ${OUTPUT}
}

function log() {
    if [[ "$1" =~ ^ERROR* ]]; then
        eval "$2='\033[91m\033[1m$1\033[0m'"
    elif [[ "$1" =~ ^Running* ]]; then
        eval "$2='\033[1m$1\033[0m'"
    elif [[ "$1" =~ ^WARNING* ]]; then
        eval "$2='\033[1m$1\033[0m'"
    else
        eval "$2='\033[92m\033[1m$1\033[0m'"
    fi
}

function checkpath(){
    local mypath="$1"
    if [[  "$mypath" = "/"  ]]; then
        echo "ERROR: Can not use root path / as path" | tee -a ${OUTPUT}
        usage
        exit 1
    fi
    if [ ! -d "$mypath" ]; then
        echo "ERROR: $mypath not found in node." | tee -a ${OUTPUT}
        usage
        exit 1
    fi
}

function check_os_distribution(){
    output=""
    echo "Checking OS Distribution" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/os_distribution_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: The OS must be RedHat" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_os_version(){
    output=""
    echo "Checking OS Virsion" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/os_distribution_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: The OS must be RedHat 7.6" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_processor(){
    output=""
    echo "Checking Processor Type" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/processor_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: Processor type must be x86_64" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_sse(){
    output=""
    echo "Checking SSE4.2 instruction supported" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/sse_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "WARNING: Streaming SIMD Extensions 4.2 is not supported on this node" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_fix_semaphore(){
    output=""
    echo "Checking kernel semaphore parameter" | tee -a ${OUTPUT}
    if [[ ${FIX} -eq 1 ]]; then
        ansible-playbook -i hosts_openshift openshift/playbook/semaphore_fix.yml > ${ANSIBLEOUT}
    else
        ansible-playbook -i hosts_openshift openshift/playbook/semaphore_check.yml > ${ANSIBLEOUT}
    fi

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: Current semaphore setting is not compatible with Cloud Pak for Data" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_cronjob(){
    output=""
    echo "Checking pre-existing cronjob" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/cronjob_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "WARNING: Streaming SIMD Extensions 4.2 is not supported on this node" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_fix_selinux(){
    output=""
    echo "Checking SELinux is enforcing" | tee -a ${OUTPUT}
    if [[ ${FIX} -eq 1 ]]; then
        ansible-playbook -i hosts_openshift openshift/playbook/selinux_fix.yml > ${ANSIBLEOUT}
    else
        ansible-playbook -i hosts_openshift openshift/playbook/selinux_check.yml > ${ANSIBLEOUT}
    fi

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: SElinux is not in enforcing mode" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_fix_clocksync(){
    output=""
    echo "Checking timesync status" | tee -a ${OUTPUT}
    if [[ ${FIX} -eq 1 ]]; then
        ansible-playbook -i hosts_openshift openshift/playbook/clocksync_fix.yml > ${ANSIBLEOUT}
    else
        ansible-playbook -i hosts_openshift openshift/playbook/clocksync_check.yml > ${ANSIBLEOUT}
    fi

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: System clock is currently not synchronised, use ntpd or chrony to sync time" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_fix_firewalld(){
    output=""
    echo "Checking firewalld status" | tee -a ${OUTPUT}
    if [[ ${FIX} -eq 1 ]]; then
        ansible-playbook -i hosts_openshift openshift/playbook/firewalld_fix.yml > ${ANSIBLEOUT}
    else
        ansible-playbook -i hosts_openshift openshift/playbook/firewalld_check.yml > ${ANSIBLEOUT}
    fi

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: Firewalld is not currently disabled" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_hostname(){
    output=""
    echo "Checking if hostname is in lowercase characters" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/hostname_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: Only lowercase characters are supported in the hostname" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_rootsize(){
    output=""
    echo "Checking size of root partition" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/rootsize_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "WARNING: size of root partition is smaller than ${root_size}G, This should be fine as long as $CRIODOCKERINSTALLPATH, /var/lib/etcd, /var/log. /tmp are mounted on separate partitions" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_disklatency(){
    output=""
    echo "Checking Disk Latency" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/disklatency_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: Disk latency test failed. By copying 512 kB, the time must be shorter than 60s, recommended to be shorter than 10s." result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_diskthroughput(){
    output=""
    echo "Checking Disk Throughput" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/diskthroughput_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: Disk throughput test failed. By copying 1.1 GB, the time must be shorter than 35s, recommended to be shorter than 5s" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_dockerdir(){
    output=""
    echo "Checking Docker folder defined" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/dockerdir_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: Directory "$CRIODOCKERINSTALLPATH" does not exists. Please setup the directory and rerun the tests" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_dockerdir_size(){
    output=""
    echo "Checking Docker container storage size" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/dockerdir_size_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: Docker target filesystem does not have enough storage. The minimum recommended is 200GB " result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_dockerdir_type(){
    output=""
    echo "Checking XFS FSTYPE for docker storage" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/dockerdir_type_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: Docker target filesystem must be formatted with ftype=1. Please reformat or move the docker location" result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_ibmartifactory(){
    output=""
    echo "checking connectivity to IBM Artifactory servere" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/ibmregistry_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "WARNING: cp.icr.io is not reachable. Enabling proxy might fix this issue." result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_redhatartifactory(){
    output=""
    echo "checking connectivity to RedHat Artifactory servere" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/ibmregistry_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "WARNING: registry.redhat.io is not reachable. Enabling proxy might fix this issue." result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

function check_gateway(){
    output=""
    echo "Checking Default Gateway" | tee -a ${OUTPUT}
    ansible-playbook -i hosts_openshift openshift/playbook/gateway_check.yml > ${ANSIBLEOUT}

    if [[ `egrep 'unreachable=[1-9]|failed=[1-9]' ${ANSIBLEOUT}` ]]; then
        log "ERROR: default gateway is not setup " result
        cat ${ANSIBLEOUT} >> ${OUTPUT}
        ERROR=1
    else
        log "[Passed]" result
    fi
    LOCALTEST=1
    output+="$result"

    if [[ ${LOCALTEST} -eq 1 ]]; then
        printout "$output"
    fi
}

#######################
### Start Pre-check ###
#######################
#For internal usage
NODETYPE="{{ type }}" 
INSTALLPATH="{{ path }}"
OCUSER="{{ ocuser }}"
PCPASS="{{ ocpassword }}"
DATAPATH="DATAPATH_PLACEHOLDER"
DOCKERDISK="DOCKERDISK_PLACEHOLDER"
CPD=0
OCP=0
FIX=0
OCPASS=""
OCLOGIN=0
CPU=16
RAM=64
WEAVE=0
pb_run=0
centos_repo=0
root_size=50
install_path_size=200
data_path_size=200
CRIODOCKERINSTALLPATH=/var/lib/docker
CONTAINERHOMESIZE=200

#Global parameter
WARNING=0
ERROR=0
LOCALTEST=0


#input check
if [[  $# -lt 1  ]]; then
    usage
    exit 1
else
    for i in "$@"
    do
    case $i in

        --help)
            helper
            exit 1
            ;;

        --install=*)
            INSTALLTYPE="${i#*=}"
            shift
            if [[ "$INSTALLTYPE" = "ocp" ]]; then
                OCP=1
            elif [[ "$INSTALLTYPE" = "cpd" ]]; then
                CPD=1
            else
                echo "please only specify install type ocp/cpd"
                exit 1
            fi            
            ;;

        --installpath=*)
            INSTALLPATH="${i#*=}"
            shift
            checkpath $INSTALLPATH
            ;;

        --ocuser=*)
            OCUSER="${i#*=}"
            shift
            ;;

        --ocpassword=*)
            OCPASS="${i#*=}"
            shift
            ;;

        --fix)
            FIX=1
            shift
            ;;

        *)
            echo "Sorry the argument is invalid"
            usage
            exit 1
            ;;
    esac
    done
fi

if [[ $OCP ]]; then
    #check_os_distribution
    #check_os_version
    #check_processor
    #check_sse
    #check_fix_semaphore
    #check_cronjob
    #check_fix_selinux
    #check_fix_clocksync
    #check_fix_firewalld
    #check_hostname
    #check_rootsize
    #check_disklatency
    #check_diskthroughput
    check_dockerdir
    check_dockerdir_size
    check_dockerdir_type
    check_ibmartifactory
    check_redhatartifactory
    check_gateway
fi
