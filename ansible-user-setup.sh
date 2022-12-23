#!/bin/bash

HOSTS="wandsworth.ankersen.dev"
USER="root"

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
  --args "key={{ lookup('file', 'files/id_ed25519-ansible.pub') }} \
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
          dest='/etc/sudoers.d/010_all-nopasswd'" \
  --become \
  --ask-become-pass \
  --ask-pass
