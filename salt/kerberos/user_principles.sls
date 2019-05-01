{% for user in pillar['users'] %}
Add user {{ user }} principle:
    cmd.run:
        - name: "kadmin.local addprinc -pw '{{ pillar['lab_user_initial_password'] }}' {{ user }}"
{% endfor %}