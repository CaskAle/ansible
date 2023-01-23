#!/bin/bash

HOSTS="services.ankersen.dev"
USER="troy"

echo "Creating ansible user on ${HOSTS} group."
echo ""

# create group nopasswd
ansible ${HOSTS} \
  --user ${USER} \
  --module-name group \
  --args "name=nopasswd \
          state=present \
          system=true" \
  --become \
  --ask-become-pass \
  --ask-pass

# ensure sudoers allowance for group nopasswd
ansible ${HOSTS} \
  --user ${USER} \
  --module-name copy \
  --args "mode='0440' \
          content='%ansible ALL=(ALL:ALL) NOPASSWD: ALL\n' \
          dest='/etc/sudoers.d/010_nopasswd'" \
  --become \
  --ask-become-pass \
  --ask-pass

# ensure ansible user exists
ansible ${HOSTS} \
  --user ${USER} \
  --module-name user \
  --args "name=ansible \
          groups=nopasswd \
          state=present \
          shell='/bin/bash'" \
  --become \
  --ask-become-pass \
  --ask-pass

# add authorized key for ansible user
ansible ${HOSTS} \
  --user ${USER} \
  --module-name authorized_key \
  --args "key={{ lookup('file', 'files/id_ed25519-ansible.pub') }} \
          user=ansible state=present \
          exclusive=true" \
  --become \
  --ask-become-pass \
  --ask-pass
