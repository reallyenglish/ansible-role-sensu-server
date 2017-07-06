# ansible-role-sensu-server

Configures `sense-server`.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `sensu_server_user` | user name of `sensu-server` | `{{ __sensu_server_user }}` |
| `sensu_server_group` | group name of `sensu-server` | `{{ __sensu_server_group }}` |
| `sensu_server_service` | service name of `sensu-server` | `{{ __sensu_server_service }}` |
| `sensu_server_config_dir` | path to configuration directory | `{{ __sensu_server_config_dir }}` |
| `sensu_server_config_file` | path to `config.json` | `{{ sensu_server_config_dir }}/config.json` |
| `sensu_server_conf_d_dir` | path to `conf.d` directory | `{{ sensu_server_config_dir }}/conf.d` |
| `sensu_server_extensions_dir` | path to `extensions` directory | `{{ sensu_server_config_dir }}/extensions` |
| `sensu_server_plugins_dir` | path to `plugins` directory | `{{ sensu_server_config_dir }}/plugins` |
| `sensu_server_log_dir` | path to log directory | `/var/log/sensu` |
| `sensu_server_flags` | not used yet | `""` |
| `sensu_server_config` | YAML representation of `config.json` | `{}` |
| `sensu_server_config_fragments` | YAML representation of JSON files under `conf.d` | `{}` |
| `sensu_server_gems` | list of dict of gems to install or remove (see below) | `[]` |
| `sensu_server_gem_binary` | path to gem binary (see below) | `gem` |

## `sensu_server_gems`

This variable is a list of dict. The dict is described below. See `ansible`
[`gem`](http://docs.ansible.com/ansible/gem_module.html) module for details.

| Key | Value | Mandatory? |
|-----|-------|------------|
| `name` | name of gem | yes |
| `state` | state of gem . one of `present`, `absent` and `latest` | yes |
| `verison` | version of gem  | no |
| `pre_release` | indicates the version is pre-release. `yes` or `no` | no |
| `repository` | repository where the gem is in | no |

## `sensu_server_gem_binary`

This is string of path to `gem` binary to use when managing plug-ins. When
`sensu` package is one from the official project, it must be path to `gem`
binary bundled in the package.

## Debian

| Variable | Default |
|----------|---------|
| `__sensu_server_user` | `sensu` |
| `__sensu_server_group` | `sensu` |
| `__sensu_server_service` | `sensu-server` |
| `__sensu_server_config_dir` | `/etc/sensu` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__sensu_server_user` | `sensu` |
| `__sensu_server_group` | `sensu` |
| `__sensu_server_service` | `sensu-server` |
| `__sensu_server_config_dir` | `/usr/local/etc/sensu` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__sensu_server_user` | `_sensu` |
| `__sensu_server_group` | `_sensu` |
| `__sensu_server_service` | `sensu_server` |
| `__sensu_server_config_dir` | `/etc/sensu` |

## RedHat

| Variable | Default |
|----------|---------|
| `__sensu_server_user` | `sensu` |
| `__sensu_server_group` | `sensu` |
| `__sensu_server_service` | `sensu-server` |
| `__sensu_server_config_dir` | `/etc/sensu` |

# Dependencies

* reallyenglish.freebsd-repos (FreeBSD only)

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - name: reallyenglish.apt-repo
      when: ansible_os_family == 'Debian'
    - name: reallyenglish.redhat-repo
      when: ansible_os_family == 'RedHat'
    - name: reallyenglish.language-ruby
      when: ansible_os_family == 'OpenBSD'
    - name: reallyenglish.freebsd-repos
      when: ansible_os_family == 'FreeBSD'
    - ansible-role-sensu-server
  vars:
    redhat_repo:
      sensu:
        baseurl: https://sensu.global.ssl.fastly.net/yum/$releasever/$basearch
        gpgcheck: no
        enabled: yes
    apt_repo_keys_to_add:
      - https://sensu.global.ssl.fastly.net/apt/pubkey.gpg
    apt_repo_enable_apt_transport_https: yes
    apt_repo_to_add:
      - "deb https://sensu.global.ssl.fastly.net/apt {{ ansible_distribution_release }} main"
    freebsd_repos:
      sensu:
        enabled: "true"
        url: https://sensu.global.ssl.fastly.net/freebsd/FreeBSD:10:amd64/
        mirror_type: srv
        signature_type: none
        priority: 100
        state: present
    sensu_server_config: {}
    sensu_server_config_fragments:
      transport:
        transport:
          name: rabbitmq
          reconnect_on_error: True
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [qansible](https://github.com/trombik/qansible)
