# Playbooks
## PXE Boot Server
### Description
Playbook to install and configure a PXE boot server for your local environment.

### Pre-requisites
1. Ansible
    - [Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
2. Two machines/virtual machines:
    - Machine Minimum Specs:
        - PXE Server:
            - 2 vCPUs
            - 2 GB RAM
            - 60 GB Disk
                - Partitions:
                    | Name | Size (GB) |
                    | ---- | ---- |
                    | / | 9 |
                    | /boot | 1 |
                    | /boot/efi | 1 |
                    | /home | 4 |
                    | /tmp | 4 |
                    | /var | 28 |
                    | /var/log | 4 |
                    | /var/log/audit | 4 |
                    | /var/tmp | 4 |
        - Test Server:
            - 2 vCPUS
            - 2 GB RAM
            - 40 GB Disk
                - Partitions:
                    | Name | Size (GB) |
                    | ---- | ---- |
                    | / | 10 |
                    | /boot | 1 |
                    | /boot/efi | 1 |
                    | /home | 8 |
                    | /tmp | 4 |
                    | /var | 4 |
                    | /var/log | 4 |
                    | /var/log/audit | 4 |
                    | /var/tmp | 4 |

    - Note: I suggest installing a hypervisor and using virtual machines. Here's a list of common affordable hypervisors
        - HyperV (Windows)
        - KVM (Linux)
        - VirtualBox (Cross Platform)
3. OS images to offer as PXE boot options
4. Kickstarts for images to offer as PXE boot options

### Usage
1. Clone Repository
    ```bash
    git clone https://github.com/danagarcia/linux-automation.git
    ```
2. Edit Inventory
    ```bash
    cd linux-automation
    vi ansible/inventory
    ```
    - Replace: 192.168.86.46 with the IPv4 address of the server you want to serve as a PXE boot server
3. Edit Variables
    ```bash
    cd linux-automation
    vi ansible/playbooks/configure-pxe-server.yml
    ```
    - Update values to match your configuration for variables:
        - home -> vars -> images
        - home -> vars -> dhcp_config
4. Generate SSH Key
    ```bash
    ssh-keygen -b 4096
    ```
5. Add Key to Authorized Keys
    ```bash
    ssh-copy-id -i ~/.ssh/<name-of-your-key>.pub <username-for-pxe-machine>@<ipv4-address-for-pxe-machine>
    ```
    - Replace vaalues between <>
6. Update Ansible Config
    ```bash
    vi ansible/ansible.cfg
    ```
    Update values for remote_user and private_key_file
7. Create Ansible Temp Directory
    ```bash
    ssh <username-for-pxe-machine>@<ipv4-address-for-pxe-machine> -i ~/.ssh/<name-of-your-key>
    sudo mkdir /var/ansible
    chmod 777 -R /var/ansible
    exit
    ```
8. Run Playbook
   ```bash
   ansible-playbook ./playbooks/configure-pxe-server.yml --become --ask-become-pass
   ```
   - You will be prompted for the password of the remote user account. This is to evelate to root as many steps require it.
9. Watch The Magic
10. Launch PXE Boot on Test Machine
11. Select Image
12. Watch The Magic
