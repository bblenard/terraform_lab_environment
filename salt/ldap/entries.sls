python-ldap:
  pkg.installed

Start ldap:
  service.running:
    - name: slapd

Generate init.ldif:
  file.managed:
    - name: "/etc/openldap/init.ldif"
    - source: salt://ldap/files/init.ldif.jinja
    - template: jinja
    - mode: 0600
    - show_changes: true
    - user: ldap
    - group: ldap