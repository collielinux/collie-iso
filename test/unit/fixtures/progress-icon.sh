# Stands in for Collie's install/provisioning/progress-icon.sh, which
# build-iso.sh vendors into the ISO from the runtime package, so dashboard tests
# run without an Collie runtime. They cover the dashboard around the progress
# screen; the screen itself is tested where it lives, in the collie repo.
progress_icon_layout() { :; }
progress_icon_static() { :; }
progress_icon_frame() { :; }
progress_icon_finish() { :; }
