base:
  '*':
    - common
  'login*':
    - ldap.server
    - ldap.entries
    - chrony
    - kerberos.server
  # 'dns':
  #   - bind

