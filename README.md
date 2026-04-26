## Project Overview
WSU CPT_S 427 Project for secure fleet management of distributed systems using Ansible, Chef, and Nagios. 
VMs created and hosted on a remote Proxmox server using Terraform. Comes with a fault-tolerant webapp, database server, and a CPU stress fault injection to experiment with.  

### Themes 
Cloud infrastructure components  -- Infrastructure is created and managed entirely with cloud platform tools.  
Secure scaling and deployment -- Scaling can be performed with Terraform and secure Proxmox API.  
Fault tolerance  -- database failover server, hosting a replica of the main database.  
Distributed system security -- SSH keys, API keys on a secure remote server, central nodes, secure central server    

### Design
This project has a control node and four worker nodes, where one of the workers is dedicated to Nagios monitoring.
The division of responsibility is node-based:  
- Control  
  - Runs Ansible playbooks to the nodes
  - I decided to have Ansible run the Chef Workstation by copying over the chef repo developed locally on my computer to avoid having to SSH into the control node to develop it. This also made it easier to centrally manage the Chef module, by having one playbook that can be run individually for each node.
  - Home of the Chef Workstation   

- Node 1: Hosts the PostgreSQL database.
- Node 2: Display fleet information. Requests the DB from the primary server then switches to the replica on Node 3 upon three failed requests. Rechecks for availability from primary DB  upon page refresh.  
- Node 3: Database Failover. Replicates the Node 1 database once per hour.
- Nagios node: Solely used for monitoring nodes 1-3

### Trade-offs
- The database server was prioritized to have a failover over the webapp, since it is more important to keep the data safe.  
- Using Ansible via Python code vs directly on the command line

### Limitations
- No failover replica for the webapp
- No rollback/teardown playbooks. Could be a security risk if remotely ending webapp or database service is needed.

### Challenges Encountered and Lessons Learned
- The first hurdle, getting Terraform to work remotely with the Proxmox server, was the biggest one. I learned a lot about VMs and remote servers.
- I initially wanted to make the entire project a python code base, but I realized this wouldn't play nicely with the amount of refactoring and design choices I made, particularly with Ansible.  
- Learned how to make a simple, decoupled distributed system, where servers are modular and only rely on the central control node rather than each other.