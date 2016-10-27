#
# Copyright (C) 2016 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This tool is prebuilt if we're doing an app-only build.


# ==========================================================
# Setup some common variables for the different build
# targets here.
# ==========================================================
LOCAL_PATH:= $(call my-dir)

aoptHostStaticLibs := \
    libandroidfw-static \
    libpng \
    liblog \
    libexpat_static \
    libutils \
    libcutils \
    libziparchive \
    libbase \
    libm \
    libc \
    libz \
    libc++_static 

CFLAGS := \
	-DHAVE_SYS_UIO_H \
	-DHAVE_PTHREADS \
	-DHAVE_SCHED_H \
	-DHAVE_SYS_UIO_H \
	-DHAVE_IOCTL \
	-DHAVE_TM_GMTOFF \
	-DANDROID_SMP=1  \
	-DHAVE_ENDIAN_H \
	-DHAVE_POSIX_FILEMAP \
	-DHAVE_OFF64_T \
	-DHAVE_ENDIAN_H \
	-DHAVE_SCHED_H \
	-DHAVE_LITTLE_ENDIAN_H \
	-D__ANDROID__ \
	-DHAVE_ANDROID_OS=1 \
	-D_ANDROID_CONFIG_H \
	-D_BYPASS_DSO_ERROR \
	-DHAVE_ERRNO_H='1' \
	-DSTATIC_ANDROIDFW_FOR_TOOLS \
	
aoptcppFlags := -std=gnu++14 \
		-Wno-missing-field-initializers \
		-fno-exceptions -fno-rtti -O2

aoptCflags := -D'AOPT_VERSION="android-$(PLATFORM_VERSION)-$(TARGET_BUILD_VARIANT)"'
aoptCflags += -Wno-format-y2k
aoptCflags += $(CFLAGS)

aoptHostLdLibs := -lc -lgcc -ldl -lz -lm 

aoptIncludes := \
        $(LOCAL_PATH)/include \
        system/core/base/include \
        system/core/libutils \
        system/core/liblog \
        system/core/libcutils \
        $(LOCAL_PATH)/libpng \
        external/expat \
        external/zlib \
        external/libcxx/include \
        system/core/libziparchive \
        frameworks/base/libs/androidfw \
        frameworks/base/include/androidfw
        
# ==========================================================
# Build the target static library: libandroidfw-static
# ==========================================================
include $(CLEAR_VARS)

ANDROIDFW_PATH := ../../libs/androidfw
LOCAL_C_INCLUDES := $(LOCAL_PATH)/
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_C_INCLUDES)

androidfw_srcs := \
    $(ANDROIDFW_PATH)/Asset.cpp \
    $(ANDROIDFW_PATH)/AssetDir.cpp \
    $(ANDROIDFW_PATH)/AssetManager.cpp \
    $(ANDROIDFW_PATH)/LocaleData.cpp \
    $(ANDROIDFW_PATH)/misc.cpp \
    $(ANDROIDFW_PATH)/ObbFile.cpp \
    $(ANDROIDFW_PATH)/ResourceTypes.cpp \
    $(ANDROIDFW_PATH)/StreamingZipInflater.cpp \
    $(ANDROIDFW_PATH)/TypeWrappers.cpp \
    $(ANDROIDFW_PATH)/ZipFileRO.cpp \
    $(ANDROIDFW_PATH)/ZipUtils.cpp \
    $(ANDROIDFW_PATH)/BackupData.cpp \
    $(ANDROIDFW_PATH)/BackupHelpers.cpp \
    $(ANDROIDFW_PATH)/CursorWindow.cpp \
    $(ANDROIDFW_PATH)/DisplayEventDispatcher.cpp

LOCAL_MODULE:= libandroidfw-static
LOCAL_MODULE_TAGS := optional
LOCAL_CFLAGS :=  $(aoptCflags)
LOCAL_CPPFLAGS := $(aoptCppFlags)
LOCAL_C_INCLUDES := external/zlib
LOCAL_STATIC_LIBRARIES := libziparchive libbase
LOCAL_SRC_FILES := $(androidfw_srcs)
include $(BUILD_STATIC_LIBRARY)


# ==========================================================
# Build the host executable: aopt
# ==========================================================
include $(CLEAR_VARS)

aoptMain = Main.cpp
aoptSources = \
    AoptAssets.cpp \
    AoptConfig.cpp \
    AoptUtil.cpp \
    AoptXml.cpp \
    ApkBuilder.cpp \
    Command.cpp \
    CrunchCache.cpp \
    FileFinder.cpp \
    Images.cpp \
    Package.cpp \
    pseudolocalize.cpp \
    Resource.cpp \
    ResourceFilter.cpp \
    ResourceIdCache.cpp \
    ResourceTable.cpp \
    SourcePos.cpp \
    StringPool.cpp \
    WorkQueue.cpp \
    XMLNode.cpp \
    ZipEntry.cpp \
    ZipFile.cpp \
    logstubs.cpp 


LOCAL_CFLAGS :=  $(aoptCflags)
LOCAL_CPPFLAGS := $(aoptCppFlags)
LOCAL_C_INCLUDES := $(aoptIncludes)
LOCAL_STATIC_LIBRARIES := $(aoptHostStaticLibs)        
LOCAL_LDLIBS := $(aoptHostLdLibs) 
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES := $(aoptMain) $(aoptSources)

LOCAL_UNSTRIPPED_PATH := $(PRODUCT_OUT)/symbols/utilities
LOCAL_LDFLAGS += -static
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_PACK_MODULE_RELOCATIONS := false
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk


LOCAL_MODULE := aopt
# Disable multilib build for now new build system makes it difficult
# I can switch to one or the other but creating and using an intermediates-dir
# thats arch specific is not working, using the same  method as debuggered and linker
# also fails 
# 

LOCAL_MODULE_STEM_32 := aopt
LOCAL_MODULE_STEM_64 := aopt64
LOCAL_MODULE_PATH_32 := $(ANDROID_PRODUCT_OUT)/system/bin
LOCAL_MODULE_PATH_64 := $(ANDROID_PRODUCT_OUT)/system/bin
LOCAL_MULTILIB := both

include $(BUILD_EXECUTABLE)

#include $(call first-makefiles-under,$(LOCAL_PATH))
