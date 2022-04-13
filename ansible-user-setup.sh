#!/bin/bash

HOSTS="arch"
USER="troy"

echo "Creating ansible user on ${HOSTS} group."
echo ""

# ensure ansible user exists
ansible ${HOSTS} \
  --user ${USER} \
  --module-name user \
  --args "name=ansible \
          state=present" \
  --become \
  --ask-become-pass \
  --ask-pass

# add authorized key for ansible user
ansible ${HOSTS} \
  --user ${USER} \
  --module-name authorized_key \
  --args "key={{ lookup('file', '/home/troy/data/keys/ssh/id_ed25519-ansible.pub') }} \
          user=ansible state=present" \
  --become \
  --ask-become-pass \
  --ask-pass

# ensure sudoers allowance for group ansible
ansible ${HOSTS} \
  --user ${USER} \
  --module-name copy \
  --args "mode='0440' \
          content='%ansible ALL=(ALL:ALL) NOPASSWD: ALL\n' \
          dest='/etc/sudoers.d/ansible'" \
  --become \
  --ask-become-pass \
  --ask-pass