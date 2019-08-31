#!/usr/bin/env bash

for tag in include_tasks_deprecated include_tasks include_playbook import_playbook
do
    echo Testing ${tag}
    ansible-playbook include_import_playbook.yml --tag ${tag}
done
