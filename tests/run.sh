#!/bin/sh
# Check the role/playbook's syntax.
ansible-playbook -i tests/inventory tests/test.yml --syntax-check || exit 1
# Run the role/playbook with ansible-playbook.
ansible-playbook -i tests/inventory tests/test.yml --connection=local --sudo || exit 1
# Run the role/playbook again, checking to make sure it's idempotent.
output_log=output_log.log
ansible-playbook -i tests/inventory tests/test.yml --connection=local --sudo -v > $output_log || exit 1
grep -q 'changed=0.*failed=0' $output_log \
    && (echo 'IDEMPOTENCE TEST: OK' && exit 0) \
    || (echo 'IDEMPOTENCE TEST: FAILED' && cat $output_log && exit 1) || exit 1
