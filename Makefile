TARGET = iphone:clang:16.5:14.0
ARCHS = arm64
MODULES = jailed
FINALPACKAGE = 1
CODESIGN_IPA = 0
PACKAGE_VERSION = X.X.X-X.X

libFLEX_ARCHS = arm64

TWEAK_NAME = YTLitePlus
DISPLAY_NAME = YouTube
BUNDLE_ID = com.google.ios.youtube

EXTRA_CFLAGS := -I$(THEOS_PROJECT_DIR)/Tweaks

# Allow YouTubeHeader to be accessible using #include <...>
export ADDITIONAL_CFLAGS = -I$(THEOS_PROJECT_DIR)/Tweaks

YTLitePlus_INJECT_DYLIBS = Tweaks/YTLite/var/jb/Library/MobileSubstrate/DynamicLibraries/YTLite.dylib .theos/obj/YouPiP.dylib .theos/obj/YouTubeDislikesReturn.dylib .theos/obj/YTABConfig.dylib .theos/obj/DontEatMyContent.dylib .theos/obj/YTVideoOverlay.dylib .theos/obj/YouGroupSettings.dylib .theos/obj/YouQuality.dylib
YTLitePlus_FILES = YTLitePlus.xm $(shell find Source -name '*.xm' -o -name '*.x' -o -name '*.m') $(shell find Tweaks/FLEX -type f \( -iname \*.c -o -iname \*.m -o -iname \*.mm \))
YTLitePlus_IPA = ./tmp/Payload/YouTube.app
YTLitePlus_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unsupported-availability-guard -Wno-unused-but-set-variable -DTWEAK_VERSION=$(PACKAGE_VERSION) $(EXTRA_CFLAGS)
YTLitePlus_FRAMEWORKS = UIKit Security
YTLitePlus_USE_FISHHOOK = 0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS +=  Tweaks/YouPiP Tweaks/Return-YouTube-Dislikes Tweaks/YTABConfig Tweaks/DontEatMyContent Tweaks/YTVideoOverlay Tweaks/YouQuality Tweaks/YouGroupSettings
include $(THEOS_MAKE_PATH)/aggregate.mk

YTLITE_PATH = Tweaks/YTLite
YTLITE_VERSION := 5.0.2
YTLITE_DEB = $(YTLITE_PATH)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm64.deb
YTLITE_DYLIB = $(YTLITE_PATH)/var/jb/Library/MobileSubstrate/DynamicLibraries/YTLite.dylib
YTLITE_BUNDLE = $(YTLITE_PATH)/var/jb/Library/Application\ Support/YTLite.bundle
before-package::
	@echo -e "==> \033[1mMoving tweak's bundle to Resources/...\033[0m"
	@cp -R Tweaks/YTLite/var/jb/Library/Application\ Support/YTLite.bundle Resources/
	@cp -R Tweaks/YouPiP/layout/Library/Application\ Support/YouPiP.bundle Resources/
	@cp -R Tweaks/Return-YouTube-Dislikes/layout/Library/Application\ Support/RYD.bundle Resources/
	@cp -R Tweaks/YTABConfig/layout/Library/Application\ Support/YTABC.bundle Resources/
	@cp -R Tweaks/DontEatMyContent/layout/Library/Application\ Support/DontEatMyContent.bundle Resources/
	@cp -R Tweaks/YTVideoOverlay/layout/Library/Application\ Support/YTVideoOverlay.bundle Resources/
	@cp -R Tweaks/YouQuality/layout/Library/Application\ Support/YouQuality.bundle Resources/
	@cp -R lang/YTLitePlus.bundle Resources/
	@echo -e "==> \033[1mChanging the installation path of dylibs...\033[0m"

internal-clean::
	@rm -rf $(YTLITE_PATH)/*

before-all::
	@if [[ ! -f $(YTLITE_DEB) ]]; then \
		rm -rf $(YTLITE_PATH)/*; \
		$(PRINT_FORMAT_BLUE) "Downloading YTLite"; \
		echo "YTLITE_VERSION: $(YTLITE_VERSION)"; \
		curl -s -L "https://github.com/dayanch96/YTLite/releases/download/v$(YTLITE_VERSION)/com.dvntm.ytlite_$(YTLITE_VERSION)_iphoneos-arm64.deb" -o $(YTLITE_DEB); \
		tar -xf $(YTLITE_DEB) -C $(YTLITE_PATH); tar -xf $(YTLITE_PATH)/data.tar* -C $(YTLITE_PATH); \
		if [[ ! -f $(YTLITE_DYLIB) || ! -d $(YTLITE_BUNDLE) ]]; then \
			$(PRINT_FORMAT_ERROR) "Failed to extract YTLite"; exit 1; \
		fi; \
	fi
