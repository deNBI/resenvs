# Fix Apt Upgrade Hanging in Ansible Tasks

## Context
The user reported that the Ansible task `[PRE_TASK Upgrade packages]` (and similar upgrade tasks) sometimes hangs. This is typically caused by:
1. **Interactive Prompts**: Some packages trigger interactive prompts during upgrades (e.g., configuration file changes). In a non-interactive CI/CD or automation environment, these prompts cause the process to wait indefinitely for user input.
2. **Infinite Lock Wait Loops**: Tasks that wait for `apt` or `dpkg` locks using shell `while` loops can hang indefinitely if the lock is never released or if the process holding the lock is itself stuck.

The goal is to ensure all `apt` upgrade tasks are non-interactive and that lock-waiting mechanisms have a timeout.

## Implementation Plan

### 1. Make Apt Upgrades Non-Interactive
For all tasks using `ansible.builtin.apt` with `upgrade: true`, `upgrade: yes`, or `upgrade: dist`, the following changes will be applied:
- Add `dpkg_options: 'force-confdef,force-confold'` to automatically handle configuration file conflicts by keeping the old version.
- Add `environment: { DEBIAN_FRONTEND: noninteractive }` to suppress interactive prompts.

**Representative files to modify:**
- `generic/generic_pre_tasks.yml`
- `cluster/roles/common/tasks/001-apt.yml`
- `vscode/docker.yml`
- `guacamole/guacamole.yml`
- `guacamole_vnc/guacamole_vnc.yml`
- `conda/conda.yml`
- `generic/setup_docker.yml`
- `generic/install_metadata_service.yml`
- `guacamole_vnc/roles/guacamole/tasks/005-desktop.yml`
- `guacamole/roles/guacamole/tasks/005-desktop.yml`

### 2. Robust Lock Waiting
Replace shell-level `while` loops with Ansible-native `until` loops to provide a timeout and better visibility.

#### In `generic/generic_pre_tasks.yml`:
Replace:
```yaml
- name: PRE_TASK Wait for any running apt/dpkg processes to finish
  ansible.builtin.shell: |
    while pgrep -x apt >/dev/null || pgrep -x apt-get >/dev/null; do
      sleep 1
    done
  retries: 20
  delay: 3
  register: apt_wait
  until: apt_wait.rc == 0
  changed_when: false
```
With:
```yaml
- name: PRE_TASK Wait for any running apt/dpkg processes to finish
  ansible.builtin.shell: pgrep -x apt || pgrep -x apt-get
  register: apt_wait
  until: apt_wait.rc != 0
  retries: 30
  delay: 5
  changed_when: false
```
*(Note: `pgrep` returns 0 if a process is found. We want to wait until no process is found, so `rc != 0` is the success condition for the loop to stop).*

#### In `cluster/roles/common/tasks/001-apt.yml`:
Replace:
```yaml
- name: PRE_TASK   Wait for automatic system updates 1
  ansible.builtin.shell: while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done;
  changed_when: false

- name: PRE_TASK  Wait for automatic system updates 2
  ansible.builtin.shell: while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 1; done;
  changed_when: false
```
With:
```yaml
- name: PRE_TASK Wait for dpkg lock
  ansible.builtin.shell: sudo fuser /var/lib/dpkg/lock
  register: lock_wait
  until: lock_wait.rc != 0
  retries: 30
  delay: 5
  changed_when: false

- name: PRE_TASK Wait for dpkg lock-frontend
  ansible.builtin.shell: sudo fuser /var/lib/dpkg/lock-frontend
  register: lock_frontend_wait
  until: lock_frontend_wait.rc != 0
  retries: 30
  delay: 5
  changed_when: false
```

## Verification Plan
Since this issue is intermittent and depends on which packages are being upgraded and the state of the system, verification will involve:
1. **Static Analysis**: Verify that all identified `apt upgrade` tasks now have the `noninteractive` environment variable and `dpkg_options`.
2. **Dry Run**: Run the affected playbooks with `--check` to ensure no syntax errors were introduced.
3. **Manual Test (Optional/If possible)**: Run the playbook on a test environment and observe if the "Upgrade packages" task completes without hanging.
