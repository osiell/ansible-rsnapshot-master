# rsnapshot (master) [![Build Status](https://travis-ci.org/osiell/ansible-rsnapshot-master.png)](https://travis-ci.org/osiell/ansible-rsnapshot-master)

Ansible role to install and configure a *rsnapshot* master. It works in
conjunction with the `rsnapshot-slave` role.

`rsnapshot-master` generates a SSH key for the `"{{rsnapshot_master_host_user}}"` system user which is by default `root`, and
`rsnapshot-slave` is charged to set up the public key for a dedicated backup system user (with limited access rights) on remote hosts.

### Running as non root user

This version allows you to run `rsnapshot` as a non-root user. In this case, you need to enable `rsnapshot_master_host_user_uses_sudo` if you want
to perform localhost backup also. 

Minimum Ansible Version: 1.4

## Supported Platforms

* Debian
    - squeeze   (6)
    - wheezy    (7)
    - jessie    (8)
    - stretch   (9)
* Ubuntu
    - precise   (12.04)
    - trusty    (14.04)

## Example (Playbook)

```yaml
- name: Backup Master
  hosts: backup_master
  sudo: yes
  roles:
    - rsnapshot-master
  vars:
    - rsnapshot_config_backup:
        - name: LOCALHOST
          points:
            - [backup, /home/, localhost/]
            - [backup, /etc/, localhost/]
            - [backup, /usr/local/, localhost/]
        - name: REMOTE_1
          points:
            - [backup, 'backupuser@192.168.1.10:/home', remote_1/]
            - [backup, 'backupuser@192.168.1.10:/etc', remote_1/]
            - [backup, 'backupuser@192.168.1.10:/var', remote_1/]
        - name: REMOTE_2
          points:
            - [backup, 'backupuser@192.168.1.20:/home', remote_2/]
            - [backup, 'backupuser@192.168.1.20:/etc', remote_2/]
            - [backup, 'backupuser@192.168.1.20:/var', remote_2/]
```

`192.168.1.10` and `192.168.1.20` hosts should be managed with the
`rsnapshot-slave` role, as below:

```yaml
- name: Hosts to backup
  hosts: remote_1:remote_2
  sudo: yes
  roles:
    - rsnapshot-slave
  vars:
    - rsnapshot_master_host: backup_master
```

See the `rsnapshot-slave` role for details about the slave configuration.

## Variables

```yaml
# SSH key for the 'root' user, the public one should be set on remote
# servers to backup (see the role 'rsnapshot-slave')
rsnapshot_master_ssh_key: id_rsa
rsnapshot_master_host_user:  root

# This is needed if you plan to backup localhost files as non root user
rsnapshot_master_host_user_uses_sudo: False

# rsnapshot options
rsnapshot_config_file: /etc/rsnapshot.conf
rsnapshot_config_version: 1.2
rsnapshot_config_snapshot_root: /var/cache/rsnapshot/
rsnapshot_config_no_create_root: 1
rsnapshot_config_cmd_cp: /bin/cp
rsnapshot_config_cmd_rm: /bin/rm
rsnapshot_config_cmd_rsync: /usr/bin/rsync
rsnapshot_config_cmd_ssh: /usr/bin/ssh
rsnapshot_config_cmd_logger: /usr/bin/logger
rsnapshot_config_cmd_du: False
rsnapshot_config_cmd_rsnapshot_diff: False
rsnapshot_config_cmd_preexec: False
rsnapshot_config_cmd_postexec: False
rsnapshot_config_intervals:
    - name: hourly
      value: 6
    - name: daily
      value: 7
    - name: weekly
      value: 4
    - name: monthly
      value: 3
rsnapshot_config_verbose: 2
rsnapshot_config_loglevel: 3
rsnapshot_config_logfile: /var/log/rsnapshot.log
rsnapshot_config_lockfile: /var/run/rsnapshot.pid
rsnapshot_config_stop_on_stale_lockfile: 0
rsnapshot_config_rsync_short_args: False
rsnapshot_config_rsync_long_args: '--delete --numeric-ids --relative --delete-excluded --rsync-path=rsync-wrapper.sh'
rsnapshot_config_ssh_args: '-i $HOME/.ssh/{{ rsnapshot_master_ssh_key }}'
rsnapshot_config_du_args: False
rsnapshot_config_one_fs: False
rsnapshot_config_include: []
rsnapshot_config_exclude: []
rsnapshot_config_include_file: False
rsnapshot_config_exclude_file: False
rsnapshot_config_link_dest: 1
rsnapshot_config_sync_first: 0
rsnapshot_config_use_lazy_deletes: 0
rsnapshot_config_rsync_numtries: 0
rsnapshot_config_backup:
    - name: LOCALHOST
      points:
          - [backup, /home/, localhost/]
          - [backup, /etc/, localhost/]
          - [backup, /usr/local/, localhost/]

# rsnapshot crontab
rsnapshot_crontab:
    - name: hourly
      month: '*'
      weekday: '*'
      day: '*'
      hour: '*/4'
      minute: 0
      job: "/usr/bin/rsnapshot hourly"
    - name: daily
      month: '*'
      weekday: '*'
      day: '*'
      hour: 3
      minute: 30
      job: "/usr/bin/rsnapshot daily"
    - name: weekly
      month: '*'
      weekday: 1
      day: '*'
      hour: 3
      minute: 0
      job: "/usr/bin/rsnapshot weekly"
    - name: monthly
      month: '*'
      weekday: '*'
      day: 1
      hour: 2
      minute: 30
      job: "/usr/bin/rsnapshot monthly"
```

## Healthcheck.io monitoring

By providing your healthcheck.io API key in the variable `healthchecks_api_key`, health checks will be automatically created 
on healthcheck.io and appened to the cron tasks.