#!/bin/bash
set -e
set -x

# exit on SIGINT (Ctrl-C in shell)
trap 'exit 1' INT

test -f obnam-local.conf || { echo "please copy obnam-local.conf.example to obnam-local.conf and adapt it to your needs."; }
cd $(dirname $0)
OBNAM="nice -n20 ionice -c3 obnam --config obnam-defaults.conf --config obnam-local.conf"
echo "last complete backup: $(test -f last_successful_backup && cat last_successful_backup || echo NEVER)."
while true; do
	upower -d | grep -q 'on-battery.*yes' && echo "Running on battery -- skipping backup." && sleep 60 && continue || true
	$OBNAM force-lock && \
	$OBNAM backup && \
	date > last_successful_backup && \
	$OBNAM forget && \
	$OBNAM generations || { echo "Error"; sleep 30; continue; }
	echo "success"
	sleep 900
done
