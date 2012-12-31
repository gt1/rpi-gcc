# rpi-gcc

Makefile for building a cross toolchain for Raspbian Wheezy armhf, including binutils 2.22 and GCC 4.7.2 with compilers for C, C++ and D ([GDC](http://gdcproject.org/)).

## Installation

Required tools:

- A reasonably recent version of GCC (tested with 4.6.2 x86\_64)
- GNU Make (version 3.82 causes problems with EGLIBC, versions prior to 3.79 too. Try 3.81.)
- git
- patch and quilt

Run make, specifying the installation directory, e.g.:

	make INST=/opt/arm-linux-gnueabihf-gcc-4.7

## Authors

Patches for EGLIBC and GCC come from the [Raspbian repository](http://archive.raspbian.org/) and [Mikhail Kupchik's tutorial](http://www.gurucoding.com/en/rpi_cross_compiler/index.php).

## Bugs

`arm-linux-gnueabihf-gdc` does not find appropriate include directories. Use `arm-linux-gnueabihf-gdmd`

## Feedback

Use [tracker](https://github.com/epi/rpi-gcc/issues) to submit patches, feature requests and bug reports.
Remember that rpi-gcc only glues together other programs and libraries, building them with specific options. If you can build the toolchain, but you find it functioning wrong or missing some features, report these problems to the respective authors of these tools instead.
