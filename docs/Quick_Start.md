# Quick Start
## Installation

Install necessary softwares:

```bash
# For Debian/Ubuntu
sudo apt-get update
sudo apt-get install build-essential git cmake perl libxml2-dev libcurl4-nss-dev python3

# For RedHat/CentOS/RockyLinux
sudo yum update
sudo yum install cmake git perl libxml2 libxml2-devel libcurl-devel python3
```

Downlaod [GMCORE Dependencies](https://drive.google.com/drive/folders/1B3ya-K4pe8y9rhM83uuGRoLgo2aWEPo1?usp=drive_link).

Extract the files with the following command:

```bash
7z x gmcore-dpds-install.7z.001
```

You will get a directory with the following structure:

```
gmcore-dpds-install/
├── hdf5-1.14.3/
│   └── ...
├── m4-1.4.19/
│   └── ...
├── netcdf-c-4.9.2/
│   └── ...
├── netcdf-fortran-4.6.1/
│   └── ...
├── szip-2.1.1/
│   └── ...
├── zlib-1.2.11/
│   └── ...
├── gmcore_install_everything.sh
├── l_BaseKit_p_2024.0.1.46_offline.sh
└── l_HPCKit_p_2024.0.1.38_offline.sh
```

Install dependencies with following command:

```bash
cd gmcore-dpds-install

bash -i gmcore_install_everything.sh
```

💡**Note**: 
- Do not forget the `-i` parameter after bash.

**After installation, you should check all log files inside "gmcore-dpds-install/logs" to see if there are any errors.**

If there are no errors, you can remove all installation files:

```bash
# Suppose you are now in "/xxx/gmcore-dpds-install"
cd ..
rm -rf gmcore-dpds-install
rm gmcore-dpds-install.7z.*
```

To clone git submodules and download test data, go to your local repository of SHUBYD-GMCORE and run the following command:

```bash
# You should be in root dir of SHUBYD-GMCORE
bash ./scripts/download.sh
```

## Build

Run the following commands to build the project:

```bash
# You should be in root dir of SHUBYD-GMCORE
bash ./scripts/build.sh
```

## Test

Run the following commands to test the project:

```bash
# You should be in root dir of SHUBYD-GMCORE
bash ./scripts/test.sh
```

