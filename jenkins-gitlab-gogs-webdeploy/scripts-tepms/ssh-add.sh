#!/usr/bin/env bash

eval $(ssh-agent.exe -s)
ssh-add.exe gitlab
ssh-add.exe -l

