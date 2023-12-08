# Tailscansible - Ansible Node with Tailscale

This doc is used to provision a VM host with a docker container running Ansible to configure remote machines over a Tailscale-based VPN mesh network using playbooks. For more information about these technologies see the documentation below:

#tailscale Documentation: https://tailscale.com/kb/
#ansible  Documentation: https://docs.ansible.com/

## Step 1 - Provision VM host

First provision a headless VM using your preferred flavour of linux with minimal resources to run the ansible docker container. Reccomended specs are:

- 1 vCPU
- 2 GB RAM
- 32 GB Disk Space

## Step 2 - Set up SSH access via Tailscale to the VM

Once your VM is initialized, use the following command to install Tailscale:

`curl -fsSL https://tailscale.com/install.sh | sh`

Then use the generated link to enroll the VM in your Tailnet.

Once you have established SSH access to the VM, for maximum security it is recommended to enable SSH via keys in a secure vault and disable password authentication in the SSH config.

you can generate an ssh key using `ssh-keygen` and copy it to the VM using `ssh-copy-id`

on systems that do not support `ssh-copy-id`, or if you are working with a vault that leverages `ssh-add -L` this command will work as well (althought you might want to run `ssh-add -L` on its own to get the key name first):

```
ssh <VM USER>@<VM IP> "echo $(ssh-add -L | grep <KEY NAME>) >> ~/.ssh/authorized_keys"
```

After adding the SSH to the VM, test SSH with the key instead of the password to ensure that adding the key was successful.

***To Disable Password Authentication for SSH on Ubuntu Server, uncomment the following lines and make the edits below to the ssh_config, sshd_config, and 50-init-cloud files in /etc/ssh***

**ssh_config**

```
   ...
   PasswordAuthentication no
   ...
   GSSAPIAuthentication no
```

**sshd_config**

```
   ...
   PermitRootLogin no
   ...
   PasswordAuthentication no
   PermitEmptyPasswords no
   ...
   UsePAM no
```

**sshd_config.d/50-cloud-init.conf**  *this one is easy to miss*

```
PasswordAuthentication no
```

Now you can restart the ssh service or reboot, and test that you have successfully disabled password authentication. 
## Step 3 - Clone or copy this repo to the VM

Clone from git or manually copy this repository to the VM you have provisioned. This can be done via sftp, git, or a number of methods, although installing  git and using  git clone is recommended, as it will be used to subsequently clone other repositories for ansible to deploy to remote machines.

`apt install git`

`git clone <REPO URL>`
## Step 4 - Build and Run Docker Container

From this directory, run these commands to build and run the docker container:

`sudo docker build -t tailscansible:latest .`

`sudo docker run -it tailscansible --restart always`

When the docker container runs for the first time, it will prompt the user to enroll it in the tailnet.

Once the tailnet enrollment is complete, confirm the installation with:

`sudo docker ps -a`

You can then start the machine with:

`sudo docker start <CONTAINER NAME>`

and open a shell in the container  using:

`sudo docker exec -it <CONTAINER NAME> /bin/bash`

once the shell opens, test the ansible instance using:

`ansible --version`

## Step 5 - Copy included configuration files to Docker Container

Copy the provided `hosts` file to the `/etc/ansible` directory using `docker cp`

`docker cp hosts <CONTAINER NAME>:/etc/ansible`





``