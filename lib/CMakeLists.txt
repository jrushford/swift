# In the absence of fine grained tablegen dependencies we need to ensure that
# Swift's libraries all build after the LLVM & Clang tablegen-generated headers
# are generated. When building out-of-tree (as with build-script) LLVM & Clang's
# CMake configuration files create these targets as dummies so we can safely
# depend on them directly here.
# See https://github.com/apple/swift/issues/48583.
#
# LLVM_COMMON_DEPENDS is a construct from the LLVM build system. It is a special
# purpose variable that provides common dependencies for all libraries, and
# executables generated when it is set. CMake's scoping rules enforce that these
# new dependencies will only be added to targets created under Swift's lib
# directory.
list(APPEND LLVM_COMMON_DEPENDS intrinsics_gen clang-tablegen-targets)

# Set up for linking against swift-syntax.
if (SWIFT_BUILD_SWIFT_SYNTAX)
  set(SWIFT_SYNTAX_MODULES
    SwiftBasicFormat
    SwiftParser
    SwiftParserDiagnostics
    SwiftDiagnostics
    SwiftSyntax
    SwiftOperators
    SwiftSyntaxBuilder
    SwiftSyntaxMacros
    SwiftSyntaxMacroExpansion
    SwiftCompilerPluginMessageHandling
    # Support for LSP
    SwiftIDEUtils
  )

  # Install shared runtime libraries
  if(CMAKE_SYSTEM_NAME MATCHES Windows)
    swift_install_in_component(TARGETS ${SWIFT_SYNTAX_MODULES}
                               RUNTIME
                               DESTINATION "bin"
                               COMPONENT swift-syntax-lib)
  else()
    swift_install_in_component(TARGETS ${SWIFT_SYNTAX_MODULES}
                               LIBRARY
                               DESTINATION "lib${LLVM_LIBDIR_SUFFIX}/swift/host"
                               COMPONENT swift-syntax-lib)
  endif()

  # Install import libraries in Windows.
  if(CMAKE_SYSTEM_NAME MATCHES Windows)
    list(TRANSFORM SWIFT_SYNTAX_MODULES
         PREPEND "${CMAKE_IMPORT_LIBRARY_PREFIX}"
         OUTPUT_VARIABLE SWIFT_SYNTAX_IMPORT_LIBRARIES)
    list(TRANSFORM SWIFT_SYNTAX_IMPORT_LIBRARIES
         APPEND "${CMAKE_IMPORT_LIBRARY_SUFFIX}"
         OUTPUT_VARIABLE SWIFT_SYNTAX_IMPORT_LIBRARIES)
    list(TRANSFORM SWIFT_SYNTAX_IMPORT_LIBRARIES
         PREPEND "${SWIFT_HOST_LIBRARIES_DEST_DIR}/"
         OUTPUT_VARIABLE SWIFT_SYNTAX_IMPORT_LIBRARIES)
    swift_install_in_component(PROGRAMS "${SWIFT_SYNTAX_IMPORT_LIBRARIES}"
                               DESTINATION lib
                               COMPONENT swift-syntax-lib)
  endif()

  add_dependencies(swift-syntax-lib
    ${SWIFT_SYNTAX_MODULES})

  # Install Swift module interface files.
  foreach(module ${SWIFT_SYNTAX_MODULES})
    set(module_dir "${module}.swiftmodule")
    set(module_file "${SWIFT_HOST_LIBRARIES_DEST_DIR}/${module_dir}/${SWIFT_HOST_MODULE_TRIPLE}")
    swift_install_in_component(FILES "${module_file}.swiftinterface" "${module_file}.private.swiftinterface"
                               DESTINATION "lib${LLVM_LIBDIR_SUFFIX}/swift/host/${module_dir}"
                               COMPONENT swift-syntax-lib)
  endforeach()

  export(TARGETS ${SWIFT_SYNTAX_MODULES}
         NAMESPACE SwiftSyntax::
         FILE ${CMAKE_BINARY_DIR}/cmake/modules/SwiftSyntaxConfig.cmake
         EXPORT_LINK_INTERFACE_LIBRARIES)
endif()

# Create a library that depends on all tool headers defined in include/module.modulemap
#
# TODO: generate this dynamically through the modulemap; this cannot use `sed`
# as that is not available on all platforms (e.g. Windows).
file(GENERATE
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/HeaderDependencies.cpp"
  CONTENT "
#define COMPILED_WITH_SWIFT
#define SWIFT_TARGET

#include \"swift/Basic/BasicBridging.h\"
#include \"swift/AST/ASTBridging.h\"
#include \"swift/IDE/IDEBridging.h\"
#include \"swift/Parse/ParseBridging.h\"
#include \"swift/SIL/SILBridging.h\"
#include \"swift/SILOptimizer/OptimizerBridging.h\"
")
add_library(importedHeaderDependencies "${CMAKE_CURRENT_BINARY_DIR}/HeaderDependencies.cpp")
# Respect LLVM_COMMON_DEPENDS as well as `add_swift_X` does to ensure
# all prerequisites like TableGen'ed headers are generated before.
add_dependencies(importedHeaderDependencies ${LLVM_COMMON_DEPENDS})

add_subdirectory(APIDigester)
add_subdirectory(AST)
add_subdirectory(ASTGen)
add_subdirectory(ASTSectionImporter)
add_subdirectory(Basic)
add_subdirectory(ConstExtract)
add_subdirectory(ClangImporter)
add_subdirectory(Demangling)
add_subdirectory(DependencyScan)
add_subdirectory(Driver)
add_subdirectory(DriverTool)
add_subdirectory(Frontend)
add_subdirectory(FrontendTool)
add_subdirectory(Index)
add_subdirectory(IDE)
add_subdirectory(IDETool)
add_subdirectory(Immediate)
add_subdirectory(IRGen)
add_subdirectory(LLVMPasses)
add_subdirectory(Localization)
add_subdirectory(Macros)
add_subdirectory(Markup)
add_subdirectory(Migrator)
add_subdirectory(Option)
add_subdirectory(Parse)
add_subdirectory(PrintAsClang)
add_subdirectory(Refactoring)
add_subdirectory(RemoteAST)
add_subdirectory(Sema)
add_subdirectory(Serialization)
add_subdirectory(SwiftDemangle)
add_subdirectory(SwiftRemoteInspection)
add_subdirectory(SwiftRemoteMirror)
add_subdirectory(SIL)
add_subdirectory(SILGen)
add_subdirectory(SILOptimizer)
add_subdirectory(StaticMirror)
add_subdirectory(SymbolGraphGen)
add_subdirectory(Threading)
