base:
  '*':
    - common
    - chrony
  'ldap*':
    - ldap.server
    - ldap.entries
  'krb*':
    - kerberos.server
  # 'dns':
  #   - bind

