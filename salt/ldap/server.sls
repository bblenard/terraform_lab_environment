Install ldap packages:
    pkg.installed:
        - pkgs:
            - openldap
            - openldap-servers
            - openldap-clients

Set SELinux context on database directory:
    selinux.fcontext_policy_present:
        - name: "{{ pillar['database_dir'] }}(/.*)?"
        - sel_type: "slapd_db_t"
        - filetype: d

Apply targed SELinux rules to database directories:
    selinux.fcontext_policy_applied:
        - name: "{{ pillar['database_dir'] }}"
        - recursive: true
        - require: 
            - selinux: "{{ pillar['database_dir'] }}(/.*)?"
        - onchanges:
            - file: "{{ pillar['database_dir'] }}/{{ pillar['suffix'] }}"

Create database directories {{ pillar['suffix'] }}:
    file.directory:
        - name: "{{ pillar['database_dir'] }}/{{ pillar['suffix'] }}"
        - user: ldap
        - group: ldap
        - dir_mode: 0700
        - makedirs: true

Slapd configuration:
    file.managed:
        - name: "/etc/openldap/slapd.conf"
        - source: salt://ldap/files/slapd.conf.jinja
        - template: jinja
        - mode: 0600
        - makedirs: true
        - show_changes: true
        - user: ldap
        - group: ldap
        - check_cmd: slaptest -u -f

Ensure slapd configuration directory exists:
    file.directory:
        - name: "/etc/openldap/slapd.d/"
        - user: root
        - group: ldap
        - dir_mode: 0770

Generate configuration directory:
    cmd.run:
        - name: slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d || true
        - runas: ldap
        - onchanges:
            - file: /etc/openldap/slapd.conf

Create ldap.conf:
    file.managed:
        - name: "/etc/openldap/ldap.conf"
        - user: root
        - group: root
        - mode: 0644
        - source: salt://ldap/files/ldap.conf.jinja
        - template: jinja
        - show_changes: true

        