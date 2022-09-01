
# ninja/parallel builds disable output colors, forcing them here.
# Needs to be at global scope to catch all targets.
# cmake will have this build into 3.24
if(CMAKE_VERSION VERSION_LESS "3.24")
	option(CMAKE_COLOR_DIAGNOSTICS "Always produce ANSI-colored output" OFF)
	if(CMAKE_COLOR_DIAGNOSTICS)
		if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
			add_compile_options("-fdiagnostics-color=always")
		elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
			add_compile_options("-fcolor-diagnostics")
		endif()
	endif()
endif()

# global scope, since ASAN needs to catch all targets
option(WANT_ASAN "build with adress sanitizer" OFF)
if(WANT_ASAN)
	add_compile_options(-fno-omit-frame-pointer -fsanitize=address)
	add_link_options(-fno-omit-frame-pointer -fsanitize=address)
endif()

# formatting and static analysis
find_program(ASTYLE_EXECUTABLE astyle)
find_program(CPPCHECK_EXECUTABLE cppcheck)

if(ASTYLE_EXECUTABLE OR CPPCHECK_EXECUTABLE)
	file(GLOB_RECURSE ALL_SRC
		${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/src/*.h)

	if(ASTYLE_EXECUTABLE)
		message(STATUS "Found source code formatter: astyle")

		list(APPEND ASTYLE_ARGS
			--suffix=none
			--style=attach
			--indent=tab=4
			--pad-oper
			--pad-header
			--unpad-paren
			--max-code-length=100
			--break-after-logical
			--attach-closing-while
			--align-pointer=type
			--align-reference=name
			--indent-classes
			--indent-preproc-block
			--indent-switches
			--min-conditional-indent=0)

		add_custom_target(format
			COMMAND ${ASTYLE_EXECUTABLE} ${ASTYLE_ARGS} ${ALL_SRC}
			COMMENT "Running astyle to format source code"
			VERBATIM)
	endif()

	if(CPPCHECK_EXECUTABLE)
		message(STATUS "Found static analysis tool: cppcheck")

		list(APPEND CPPCHECK_ARGS
			--enable=warning,style,performance,portability,unusedFunction
			#--std=c++11
			--std=c++03
			--language=c++
			-I${CMAKE_CURRENT_SOURCE_DIR}/src
			-U__SYMBIAN32__ -UUIQ3 # unmaintained
			#--enable=information
		)

		add_custom_target(cppcheck
			COMMAND ${CPPCHECK_EXECUTABLE} ${CPPCHECK_ARGS} ${ALL_SRC}
			COMMENT "Running cppcheck for static analysis"
			USES_TERMINAL VERBATIM)
	endif()
else()
	message(STATUS "No source code formatter or static analysis tool enabled.")
endif()
