#!/usr/bin/env bash
# pushd/popd, or subshell.
(
  cd deployment/k8s/helm || exit
  make uninstall
)
