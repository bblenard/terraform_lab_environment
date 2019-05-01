python-ldap:
  pkg.installed

Generate init.ldif:
  file.managed:
    - name: "/etc/openldap/init.ldif"
    - source: salt://ldap/files/init.ldif.jinja
    - template: jinja
    - mode: 0600
    - show_changes: true
    - user: ldap
    - group: ldap

Install Ldap Users:
  cmd.run:
    - name: "slapadd -l /etc/openldap/init.ldif -F /etc/openldap/slapd.d/ -c"

Fix ownership of ldap db data:
  cmd.run:
    - name: "chown -R ldap.ldap {{ pillar['database_dir'] }}"

Start ldap:
  service.running:
    - name: slapd