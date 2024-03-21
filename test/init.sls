test_file:
  file.managed:
    - name: /root/test
    - user: root
    - group: root
    - mode: 700
    - source: salt://test/files/test
