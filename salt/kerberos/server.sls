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

Configure KDC:
    file.managed:
        - name: "/var/kerberos/krb5kdc/kdc.conf"
        - source: salt://kerberos/files/kdc.conf.jinja
        - template: jinja
        - mode: 0644
        - makedirs: true
        - show_changes: true
        - user: root
        - group: root