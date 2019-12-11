# Scripts for precompiling PROBIC-affiliated software
## Requirements
Linux binaries
* docker
* bash shell

macOS binaries
* macOS machine

Note that both build pipelines may require internet access. Individual
software may have additional requirements.

## Usage
Simply enter the directory for the software and platform you wish to build
for, and run the `compile.sh` script with the correct version number
as the first argument:
```
cd linux/mSWEEP
./compile.sh 1.2.2
```
which will create the `mSWEEP_linux-v1.2.2.tar.gz` archive in the
current working directory, ready for distribution.

## License (scripts)
The source code from this project is subject to the terms of the
MIT license. A copy of the MIT license is supplied with the
project, or can be obtained at https://spdx.org/licenses/MIT.html

## License (targets)
* mSWEEP is licensed under the MIT license.
* Themisto is licensed under the GPLv2 license.
