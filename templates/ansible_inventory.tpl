---
all:
 hosts:
  aws:
   ansible_connection: ssh
   ansible_ssh_user: ubuntu
   ansible_host: ${host-ip}
   ansible_ssh_private_key_file: ${key-file}
...
