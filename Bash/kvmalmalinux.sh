#!/bin/bash

# Enable debug mode to print each command before executing it
set -x

# Function to check for hardware virtualization support
check_virtualization_support() {
    echo "Checking for hardware virtualization support..."
    if [[ $(egrep -c '(vmx|svm)' /proc/cpuinfo) -eq 0 ]]; then
        echo "Your CPU does not support hardware virtualization."
        exit 1
    else
        echo "Hardware virtualization is supported."
    fi
}

# Function to import AlmaLinux GPG key
import_gpg_key() {
    echo "Importing AlmaLinux GPG key..."
    sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux
    sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux
}

# Function to enable EPEL repository
enable_epel() {
    echo "Enabling EPEL repository..."
    sudo dnf install epel-release -y
}

# Function to clean DNF cache and update system
clean_and_update() {
    echo "Cleaning DNF cache and updating system..."
    sudo dnf clean all
    sudo rm -rf /var/cache/dnf
    sudo dnf update -y
}

# Function to install libvirt and related packages
install_libvirt() {
    echo "Installing libvirt and related packages..."
    sudo dnf install -y qemu-kvm virt-manager libvirt virt-install virt-viewer virt-top libguestfs-tools
}

# Function to load KVM modules
load_kvm_modules() {
    echo "Loading KVM modules..."
    sudo modprobe kvm
    sudo modprobe kvm_intel   # For Intel CPUs
    sudo modprobe kvm_amd     # For AMD CPUs
}

# Function to add KVM modules to be loaded at boot
persist_kvm_modules() {
    echo "Persisting KVM modules to load at boot..."
    sudo sh -c 'echo "kvm" >> /etc/modules-load.d/kvm.conf'
    sudo sh -c 'echo "kvm_intel" >> /etc/modules-load.d/kvm.conf'   # For Intel CPUs
    sudo sh -c 'echo "kvm_amd" >> /etc/modules-load.d/kvm.conf'     # For AMD CPUs
}

# Function to enable and start libvirtd service
start_libvirtd() {
    echo "Enabling and starting libvirtd service..."
    sudo systemctl enable --now libvirtd
}

# Main function to run all steps
main() {
    check_virtualization_support
    import_gpg_key
    enable_epel
    clean_and_update
    install_libvirt
    load_kvm_modules
    persist_kvm_modules
    start_libvirtd
    echo "All steps completed. Verifying libvirtd service status..."
    sudo systemctl status libvirtd
}

# Run the main function
main
