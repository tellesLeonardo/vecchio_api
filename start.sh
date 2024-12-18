#!/bin/sh

bin/vecchio_api eval "VecchioApi.Release.migrate" && \
bin/vecchio_api eval "VecchioApi.Release.seed" && \
bin/vecchio_api start