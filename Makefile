export ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Podivator
Podivator_FILES = Event.xm
Podivator_LIBRARIES = activator
Podivator_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	#PreferenceLoader plist
	$(ECHO_NOTHING)if [ -f Preferences.plist ]; then mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Podivator; cp Preferences.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Podivator/; fi$(ECHO_END)

after-install::
	install.exec "killall -9 SpringBoard"
