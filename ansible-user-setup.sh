#!/bin/bash

HOSTS='mordecai'

echo "Creating ansible user on ${HOSTS} group."
echo ""

# ensure ansible user exists
ansible ${HOSTS} \
  --module-name user \
  --args "name=ansible \
          state=present" \
  --become \
  --ask-become-pass
    
# add authorized key for ansible user
ansible ${HOSTS} \
  --module-name authorized_key \
  --args "key={{ lookup('file', '/home/troy/data/keys/ssh/id_ed25519-ansible.pub') }} \
          user=ansible state=present" \
  --become \
  --ask-become-pass
 
# ensure sudoers allowance for group ansible
ansible ${HOSTS} \
  --module-name copy \
  --args "mode='0440' \
          content='%ansible ALL=(ALL:ALL) NOPASSWD: ALL\n' \
          dest='/etc/sudoers.d/ansible'" \
  --become \
  --ask-become-pass
