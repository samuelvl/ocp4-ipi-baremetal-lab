#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Global variables
TF_VERSION="0.13.2"
TF_PROVIDERS_DIR="${HOME}/.terraform.d/plugins/registry.terraform.io/hashicorp"
TF_PROVIDER_LIBVIRT_VERSION="0.6.2"
TF_PROVIDER_LIBVIRT_RELEASE="v0.6.2/terraform-provider-libvirt-0.6.2+git.1585292411.8cbe9ad0.Fedora_28.x86_64"
VBMC_VERSION="2.1.0"
SUSHY_VERSION="0.12.0"
OC_VERSION="4.5"

# install_libvirt
function install_libvirt {
    libvirt_command="virsh"

    if (which ${libvirt_command} &> /dev/null); then    
        echo "Libvirt is already installed."
    else
        echo "Follow the instructions to install libvirt in your linux distribution."        
    fi

    return 0
}

# install_terraform <version> <installation_dir>
function install_terraform {
    tf_command="terraform"
    tf_version=${1}
    tf_installation_dir=${2}
    tf_binary="${tf_installation_dir}/${tf_command}"

    # Check if Terraform is already installed
    if (ls "${tf_binary}" &> /dev/null); then
        echo "Terraform v${tf_version} is already installed"
    else
        echo "Installing Terraform v${tf_version}..."

        # Create installation dir
        mkdir -p ${tf_installation_dir}

        # Download Terraform from Hashicorp site
        curl -s -L --output ${tf_binary}.zip \
            https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip

        # Install Terraform
        unzip -d ${tf_installation_dir} ${tf_binary}.zip
        chmod +x ${tf_binary}
        rm -f ${tf_binary}.zip

        echo "Successfully installed!"
    fi

    return 0
}

# install_tf_provider <name> <version> <installation_dir> <url> <tar_additional_opts>
function install_tf_provider {
    provider_name=${1}
    provider_version=${2}
    provider_install_dir="${3}/${provider_name}/${provider_version}/linux_amd64"
    provider_binary="${provider_install_dir}/terraform-provider-${provider_name}"
    provider_url=${4}
    tar_additional_opts=${5:-""}

    # Check if provider is already installed
    if (ls "${provider_binary}_${provider_version}" &> /dev/null); then
        echo "Terraform provider ${provider_name} v${provider_version} is already installed"
    else
        echo "Installing Terraform provider ${provider_name} v${provider_version}..."

        # Create installation folder
        mkdir -p ${provider_install_dir}

        # Download provider from source
        curl -s -L --output ${provider_binary}.tar.gz ${provider_url}

        # Install Provider
        tar -xvf ${provider_binary}.tar.gz ${tar_additional_opts} -C ${provider_install_dir}
        chmod +x ${provider_binary}
        mv ${provider_binary} "${provider_binary}_${provider_version}"
        rm -f ${provider_binary}.tar.gz

        echo "Successfully installed!"
    fi

    return 0
}

# install_vbmc <version> <systemd_dir>
function install_vbmc {
    vbmc_command="vbmc"
    vbmc_version=${1}
    vbmc_systemd_dir=${2}

    if (which ${vbmc_command} &> /dev/null); then    
        echo "VirtualVBMC v${vbmc_version} is already installed"
    else
        echo "Installing VirtualVBMC v${vbmc_version}..."

        # Install VirtualBMC
        pip3 install --user virtualbmc==${vbmc_version}

        # Setup VirtualBMC server daemon
        mkdir -p ${vbmc_systemd_dir}
        cat > ${vbmc_systemd_dir}/vbmcd.service <<-EOF
			[Unit]
			Description=VirtualBMC Server Daemon
			Wants=network-online.target
			After=network-online.target

			[Service]
			ExecStart=${HOME}/.local/bin/vbmcd --foreground

			[Install]
			WantedBy=multi-user.target
		EOF

        systemctl --user daemon-reload
        systemctl --user enable --now vbmcd

        echo "Successfully installed!"
    fi

    return 0
}

# install_sushy_emulator <version>
function install_sushy_emulator {
    sushy_command="sushy-emulator"
    sushy_version=${1}
    sushy_systemd_dir=${2}

    if ! (which ${sushy_command} &> /dev/null); then    
        echo "Sushy tools v${sushy_version} are already installed"
    else
        echo "Installing Sushy tools v${sushy_version}..."

        # Install Sushy tools
        pip3 install --user sushy-tools==${sushy_version}

        # Setup VirtualBMC server daemon
        mkdir -p ${sushy_systemd_dir}
        cat > ${sushy_systemd_dir}/sushyd.service <<-EOF
			[Unit]
			Description=Sushy Emulator Server Daemon
			Wants=network-online.target
			After=network-online.target

			[Service]
			ExecStart=${HOME}/.local/bin/sushy-emulator --config "${HOME}/.config/sushyd/emulator.conf" --libvirt-uri "qemu:///system"

			[Install]
			WantedBy=multi-user.target
		EOF

        systemctl --user daemon-reload
        systemctl --user enable --now sushyd

        echo "Successfully installed!"
    fi

    return 0
}

# install_oc <version> <installation_dir> 
function install_oc {
    oc_command="oc"
    oc_version=${1}
    oc_install_dir=${2}
    oc_binary="${oc_install_dir}/${oc_command}"

    # Check if oc is already installed
    if (ls "${oc_binary}" &> /dev/null); then
        echo "Openshift client v${oc_version} is already installed"
    else
        echo "Installing Openshift client v${oc_version}..."

        # Download oc
        curl -L --output ${oc_binary}.tar.gz \
            https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-${OC_VERSION}/openshift-client-linux.tar.gz

        # Install oc
        tar -xvf ${oc_binary}.tar.gz -C ${oc_install_dir} oc
        chmod +x ${oc_binary}
        rm -f ${oc_binary}.tar.gz

        echo "Successfully installed!"
    fi

    return 0
}

# Install libvirt
install_libvirt

# Install terraform
install_terraform ${TF_VERSION} "${HOME}/bin"

# Install libvirt provider for terraform
install_tf_provider \
    "libvirt" \
    ${TF_PROVIDER_LIBVIRT_VERSION} \
    ${TF_PROVIDERS_DIR} \
    "https://github.com/dmacvicar/terraform-provider-libvirt/releases/download/${TF_PROVIDER_LIBVIRT_RELEASE}.tar.gz"

# Install VirtualBMC
install_vbmc ${VBMC_VERSION} "${HOME}/.config/systemd/user"

# Install Sushy emulator
install_sushy_emulator ${SUSHY_VERSION} "${HOME}/.config/systemd/user"

# Install Openshift client
install_oc ${OC_VERSION} "${HOME}/bin"
