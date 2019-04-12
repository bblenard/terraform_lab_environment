Install Kerberos Server / Admin Packages:
    pkg.installed:
        - pkgs:
            - krb5-server
            - krb5-libs

Configure Realm:
    file.managed:
        - name: "/etc/krb5.conf"
        - source: salt://kerberos/files/krb5.conf.jinja
        - template: jinja
        - mode: 0644
        - makedirs: true
        - show_changes: true
        - user: root
        - group: root

Create Kerberos directory:
    file.directory:
        - name: "{{ pillar['kerberos_base_dir'] }}"
        - user: root 
        - group: root
        - recurse:
            - user
            - group
            - mode
        - dir_mode: 0755
        - makedirs: true
        - follow_symlinks: false

Configure KDC:
    file.managed:
        - name: "{{ pillar['kerberos_base_dir'] }}/kdc.conf"
        - source: salt://kerberos/files/kdc.conf.jinja
        - template: jinja
        - mode: 0644
        - makedirs: true
        - show_changes: true
        - user: root
        - group: root

Setup ACL:
    file.managed:
        - name: "{{ pillar['kerberos_base_dir'] }}/kadm5.acl"
        - source: salt://kerberos/files/kadm5.acl.jinja
        - template: jinja
        - mode: 0644
        - show_changes: true
        - user: root
        - group: root

Initialize Kerberos Realm:
    cmd.run:
        - name: "kdb5_util -P '{{ pillar['kerberos_master_key'] }}' create -s"
        - onchanges:
            - file: "{{ pillar['kerberos_base_dir'] }}"

Add lab/admin principle:
    cmd.run:
        - name: "kadmin.local addprinc -pw '{{ pillar['kerberos_lab_admin_password'] }}' lab/admin"
        - onchanges:
            - file: "{{ pillar['kerberos_base_dir'] }}"

Create keytab file:
    cmd.run:
        - name: "kadmin.local ktadd -k '{{ pillar['kerberos_base_dir'] }}/kadm5.keytab' kadmin/admin kadmin/changepw"
        - onchanges:
            - file: "{{ pillar['kerberos_base_dir'] }}"

Create Systemd unit for krb5kdc:
    file.managed:
        - name: "/etc/systemd/system/krb5kdc.service"
        - source: salt://kerberos/files/krb5kdc.service
        - mode: 0644
        - show_changes: true
        - user: root
        - group: root

Create Systemd unit for kadmind:
    file.managed:
        - name: "/etc/systemd/system/kadmind.service"
        - source: salt://kerberos/files/kadmind.service
        - mode: 0644
        - show_changes: true
        - user: root
        - group: root

Enable and Start krb5kdc:
    service.running:
        - name: krb5kdc
        - enable: true
        - require:
            - file: "/etc/systemd/system/krb5kdc.service"

Enable and Start kadmind:
    service.running:
        - name: kadmind
        - enable: true
        - require:
            - file: "/etc/systemd/system/kadmind.service"
