server_patch_check_script:
  cmd.script:
    - source: salt://postpatch/suma_postpatch.sh
    - shell: /bin/bash
