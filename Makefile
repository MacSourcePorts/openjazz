# OpenJazz makefile
include openjazz.mk

# Sane defaults
CXX ?= g++
CXXFLAGS ?= -g -Wall -O2
CPPFLAGS = -Isrc -DSCALE -Iext/scale2x -Iext/psmplug -Iext/miniz -Iext/argparse

# Network support
CXXFLAGS += -DUSE_SOCKETS
ifeq ($(OS),Windows_NT)
	# Only needed under Windows.
	LIBS += -lws2_32
endif

# SDL
CXXFLAGS += $(shell $(PREFIX)/sdl2-config --cflags)
LIBS += $(shell $(PREFIX)/sdl2-config --libs)

LIBS += -lm

.PHONY: clean

OpenJazz: $(OBJS)
	@-echo [LD] $@
	@$(CXX) -arch $(ARCH) -o OpenJazz $(LDFLAGS) $(OBJS) $(LIBS)

%.o: %.m
	@-echo [CXX] $<
	@$(CXX) -arch $(ARCH) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

%.o: %.cpp
	@-echo [CXX] $<
	@$(CXX) -arch $(ARCH) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

clean:
	@-echo Cleaning...
	@rm -f OpenJazz $(OBJS)
