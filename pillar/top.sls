base:
    '*':
        - root
        - chrony
        - users
    'ldap.*':
        - ldap
    'krb.*':
        - kerberos
