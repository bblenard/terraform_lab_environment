Install ntpd:
    pkg.installed:
        - name: chrony

Open Chrony port:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - dport: 123
        - protocol: udp
        - save: True

Configure Chrony:
    file.managed:
        - name: "/etc/chrony.conf"
        - source: salt://chrony/files/chrony.conf.jinja
        - template: jinja
        - mode: 0644
        - makedirs: true
        - show_changes: true
        - user: root
        - group: root

Start chronyd:
    service.running:
        - name: chronyd