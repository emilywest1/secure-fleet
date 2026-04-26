import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from terraform.terraform_runner.terraform import get_terraform_outputs
import ansible_runner

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def run_nrpe_install(target: str):
    result = ansible_runner.run(
        private_data_dir=os.path.join(BASE_DIR, 'playbooks'),
        playbook='install_nrpe.yml',
        extravars={
            'target_host': target,
            'nrpe_allowed_hosts': '10.175.224.209', # "nagios" named vm. to do: change this to use variable from vm_info
            'nrpe_port': 5666,
            'ansible_user': 'terraform',
        },
        verbosity=1
    )
    return result

def ansible_install_nrpe(vm_info: dict):
    for name, vm in vm_info.items():
        if name in ('control', 'nagios'):
            continue
        result = run_nrpe_install(name)
        if result.status == 'successful':
            print(f"{name} ({vm['ip']}): NRPE installed (rc={result.rc})")
        else:
            print(f"{name} ({vm['ip']}): failed, status={result.status}, rc={result.rc}")


def run_nagios_install(vm_info: dict):
    # Build the nodes dict to pass into the template
    nodes = {
        name: {'ip': vm['ip']}
        for name, vm in vm_info.items()
        if name not in ('control', 'nagios')
    }

    result = ansible_runner.run(
        private_data_dir=os.path.join(BASE_DIR, 'playbooks'),
        playbook='install_nagios.yml',
        extravars={
            'target_host': 'nagios-vm',
            'nodes': nodes,  # passed into nagios_nodes.cfg.j2
            'ansible_user': 'terraform',

        },
        verbosity=1
    )
    return result

# Install Nagios on nagios VM
def ansible_install_nagios(vm_info, nagios_ip):
    print("\nInstalling Nagios on nagios VM...")
    result = run_nagios_install(vm_info)
    if result.status == 'successful':
        print(f"Nagios installed successfully (rc={result.rc})")
        print(f"Web UI: http://{nagios_ip}/nagios4  (user: nagiosadmin)")
    else:
        print(f"Nagios install failed, status={result.status}, rc={result.rc}")
def main():

    vm_info = get_terraform_outputs()
    print("Available Virtual Machines:")
    for name, vm in vm_info.items():
        print(f"{name:<10}{vm['ip']}")

    # indexing the vm_info list: vm_info["nagios"]["ip"])
    # Precondition: install Ansible on the control node (done 03/10/2026)

    # playbook: install Nagios Remote Plugin Executor on nodes 1, 2, and 3
    #ansible_install_nrpe(vm_info)

    # playbook: set up Nagios on the nagios node and point to nodes 1, 2, and 3
    ansible_install_nagios(vm_info, vm_info["nagios"]["ip"])

if __name__ == '__main__':
    main()