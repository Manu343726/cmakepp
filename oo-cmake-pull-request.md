
# Integrate oo-cmake with [biicode](www.biicode.com) C/C++ dependency management

Hi! I'm Manu Sánchez, from the biicode team.  

I'm working intensively with CMake scripts and I find your library very useful to me. Maps, function calls, etc; features that make feasible writing complex CMake scripts without going crazy!

biicode is a file-based dependency manager for C and C++, in the same spirit of Java's Maven and Maven Central or Python's pip. The tool uses CMake under the hood to process builds, so to setup a biicode *block** you should play a bit with `CMakeLists.txt` files. *A block is our unit of code sharing, think of it as a package.*    
Here's an example, part of the `CMakeLists.txt` file of our [Box2D block](https://www.biicode.com/erincatto/erincatto/box2d/master/10):

``` cmake
IF(BIICODE)
    INCLUDE(${CMAKE_HOME_DIRECTORY}/biicode.cmake)
    INIT_BIICODE_BLOCK()
    ADD_DEFINITIONS(-DGLEW_STATIC)
    SET(BII_LIB_SYSTEM_DEPS )
    ADD_BIICODE_TARGETS()
    target_include_directories(${BII_LIB_TARGET} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
ELSE()
    cmake_minimum_required(VERSION 2.6)

    project(Box2D)

    if(UNIX)
        set(BOX2D_INSTALL_BY_DEFAULT ON)
    else(UNIX)
        set(BOX2D_INSTALL_BY_DEFAULT OFF)
    endif(UNIX)

    option(BOX2D_INSTALL "Install Box2D libs, includes, and CMake scripts" ${BOX2D_INSTALL_BY_DEFAULT})
    option(BOX2D_INSTALL_DOC "Install Box2D documentation" OFF)
    ...
ENDIF()
```

It's exactly the same `CMakeLists.txt` from the original library, just adding a couple of toggles to make it work with biicode.  
To use Box2D, you only have to `#include` it in your C/C++ code, biicode does everything else (Download, setup build, etc). [Check our docs](http://docs.biicode.com/) for more info.

Since version 2.0 we support dependency management of CMake scripts, via `include()` directives. Your library was very useful to me, so I created a block to deploy and reuse it easily across all my biicode blocks. Now I'm able to use your library inside my biicode `CMakeLists.txt` files just doing `include(manu343726/oo-cmake/oo-cmake)`.

I hope you like it.


## oo-cmake changes

I tried not to touch your codebase at all, but use Travis CI to build and publish the block from your sources. So the only changes this pull request has should be on the `.travis.yml` file (Among other minor changes on the README and the .gitignore).

### The block

The idea is to have a biicode block with all your sources, even if the main feature for biicode users is the `oo-cmake.cmake` file. Check the block [here](https://www.biicode.com/manu343726/oo-cmake).

### Dependency management

biicode is a file-based dependency management system, that means that biicode uses files as its unit of dependency. So if you use `foo.cpp` from a `manu343726/lib` block, biicode will download the `foo.cpp` file only, not the entire `manu343726/lib` block. This is interesting for large libraries and codebases, because only the `#include`d files will be downloaded.

But that does not work in this case. Your `oo-cmake.cmake` file depends in many CMake scripts and some extra C++ files that should be retrieved too, but you are not using our `include(user/block/script)` convention (And I'm not going to change your sources) so this does not work directly.
However biicode allows you to specify dependencies manually in the `biicode.conf` file, the configuration file of the block:

```
[dependencies]
    # Manual adjust file implicit dependencies, add (+), remove (-), or overwrite (=)
    # hello.h + hello_imp.cpp hello_imp2.cpp
    # *.h + *.cpp
    oo-cmake.cmake + build/* cmake/* resources/* src/*
```
In our case, I specified explicitly that `oo-cmake.cmake` depends on the contents of the `build/`, `cmake/`, `resources/`, and `test/` folders. Now biicode will download that folders when the ` oo-cmake.cmake` file is used.

### CMakeLists.txt

Each biicode block has it's own `CMakeLists.txt` with building configuration. If no CMakeLists.txt is provided, biicode generates one. By default biicode searches for any C/C++ file adding it to block targets (Library or executable, depending on the kind of file: Is it a header?, is it a `.cpp` with a `main()` function?, etc). 

This process, done by the ` ADD_BIICODE_TARGETS()` macro, works like a charm with C/C++ libraries, but not with CMake libraries that uses some C/C++ files like yours. We don't want any C/C++ target in the oo-cmake block, we don't even want a target at all since this is designed to be `include()` only. 

So simply add an empty `CMakeLists.txt` to the block. 

### Generating and publishing the block automatically

So we have to get the block, copy your library sources on it, write the custom ` biicode.conf`, and override the default biicode `CMakeLists.txt` with an empty one. Then publish the block.

If you suppose the block already exists this is easier, we just need to open the block and update its contents:

``` bash
$ bii init #Initialize biicode project
$ bii open manu343726/oo-cmake #Download the entire block for editing
$ echo "" > blocks/manu343726/oo-cmake/CMakeLists.txt #Override CMakeLists.txt
$ cp YOUR_SOURCES ./blocks/manu343726/oo-cmake/
$ bii user manu343726 #We need to log in to publish a block
$ bii publish manu343726/oo-cmake
```

What I did is to create the block using the web inteface, add the custom `biicode.conf` to it, and working in travis starting with that:

``` yaml
install: 
- wget http://apt.biicode.com/install.sh && chmod +x install.sh && ./install.sh
- bii setup:cpp
script:
- bii init
- bii open manu343726/oo-cmake
- echo "" > blocks/manu343726/oo-cmake/CMakeLists.txt
- rsync -av --exclude="blocks" --exclude="bii" --exclude=".git" --exclude=".gitignore" . blocks/manu343726/oo-cmake
- cmake -P build/script.cmake
after_success: cmake -P build/after_success.cmake
after_failure: cmake -P build/after_failure.cmake
after_script: cmake -P build/after_script.cmake
deploy:
  provider: biicode
  user: manu343726
  password:
    secure: MY ENCRYPTED BIICODE PASSWORD
  skip_cleanup: true #The biicode block is generated during build, don't discard build changes!
```

Note that Travis CI supports biicode deployment out of the box, just install the travis gem and run:

```
$ gem install travis
$ cd oo-cmake
$ travis setup biicode
```

This command will ask you for biicode credentials, some configuration flags, and then will add the `deploy` entry to your `travis.yml`.

