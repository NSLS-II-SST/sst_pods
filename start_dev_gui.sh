#! /usr/bin/bash
set -e
set -o xtrace

bash start_beamline.sh
bash dev_qs.sh
bash dev_gui.sh
