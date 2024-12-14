#!/bin/sh

bin/sysaud eval "Sysaud.Release.migrate" && \
bin/sysaud eval "Sysaud.Release.seed" && \
bin/sysaud start