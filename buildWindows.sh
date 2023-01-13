#Build OpenOCD for Windows

#This is taken from the github automation workflow https://github.com/5inf/openocd/blob/master/.github/workflows/snapshot.yml which gives a straightforward recipe.
#It has been tested on Debian bookworm

#Install needed packages
sudo apt-get update
sudo apt-get install autotools-dev autoconf automake libtool pkg-config cmake texinfo texlive g++-mingw-w64-i686

#Checkout Code
git clone https://github.com/5inf/openocd.git
#Our commit is 75de3960f53e72516e41a65729f53d5772b5620e

#Setup environment 
BUILD_DIR=`pwd`/build
DL_DIR=`pwd`/download
SRC_DIR=`pwd`/openocd
#GITHUB_ENV=`pwd`/githubenv

cd $SRC_DIR
mkdir $DL_DIR
mkdir $BUILD_DIR
./bootstrap
#./configure

#Prepare libusb1
LIBUSB1_VER=1.0.26
mkdir -p $DL_DIR && cd $DL_DIR
wget "https://github.com/libusb/libusb/releases/download/v${LIBUSB1_VER}/libusb-${LIBUSB1_VER}.tar.bz2"
tar -xjf libusb-${LIBUSB1_VER}.tar.bz2
#echo "LIBUSB1_SRC=$PWD/libusb-${LIBUSB1_VER}" >> $GITHUB_ENV
LIBUSB1_SRC=$PWD/libusb-${LIBUSB1_VER}
export LIBUSB1_SRC=$LIBUSB1_SRC
cd $SRC_DIR

#Prepare hidapi
HIDAPI_VER=0.11.2
mkdir -p $DL_DIR && cd $DL_DIR
wget "https://github.com/libusb/hidapi/archive/hidapi-${HIDAPI_VER}.tar.gz"
tar -xzf hidapi-${HIDAPI_VER}.tar.gz
cd hidapi-hidapi-${HIDAPI_VER}
./bootstrap
#echo "HIDAPI_SRC=$PWD" >> $GITHUB_ENV
HIDAPI_SRC=$PWD
export HIDAPI_SRC=$HIDAPI_SRC
cd $SRC_DIR

#Prepare libftdi
LIBFTDI_VER=1.5
mkdir -p $DL_DIR && cd $DL_DIR
wget "http://www.intra2net.com/en/developer/libftdi/download/libftdi1-${LIBFTDI_VER}.tar.bz2"
tar -xjf libftdi1-${LIBFTDI_VER}.tar.bz2
#echo "LIBFTDI_SRC=$PWD/libftdi1-${LIBFTDI_VER}" >> $GITHUB_ENV
LIBFTDI_SRC=$PWD/libftdi1-${LIBFTDI_VER}
export LIBFTDI_SRC=$LIBFTDI_SRC
cd $SRC_DIR

#Prepare capstone
CAPSTONE_VER=4.0.2
mkdir -p $DL_DIR && cd $DL_DIR
CAPSTONE_NAME=${CAPSTONE_VER}
CAPSTONE_FOLDER=capstone-${CAPSTONE_VER}
wget "https://github.com/aquynh/capstone/archive/${CAPSTONE_VER}.tar.gz"
tar -xzf ${CAPSTONE_VER}.tar.gz
#echo "CAPSTONE_SRC=$PWD/capstone-${CAPSTONE_VER}" >> $GITHUB_ENV
CAPSTONE_SRC=$PWD/capstone-${CAPSTONE_VER}
export CAPSTONE_SRC=$CAPSTONE_SRC
cd $SRC_DIR


#Package OpenOCD for windows
cd $SRC_DIR
MAKE_JOBS=2
HOST=i686-w64-mingw32
export LIBUSB1_CONFIG="--enable-shared --disable-static"
export HIDAPI_CONFIG="--enable-shared --disable-static --disable-testgui"
export LIBFTDI_CONFIG="-DSTATICLIBS=OFF -DEXAMPLES=OFF -DFTDI_EEPROM=OFF"
export CAPSTONE_CONFIG="CAPSTONE_BUILD_CORE_ONLY=yes CAPSTONE_STATIC=yes CAPSTONE_SHARED=no"

#run
# check if there is tag pointing at HEAD, otherwise take the HEAD SHA-1 as OPENOCD_TAG
OPENOCD_TAG="`git tag --points-at HEAD`"
[ -z $OPENOCD_TAG ] && OPENOCD_TAG="`git rev-parse --short HEAD`"
# check if there is tag pointing at HEAD, if so the release will have the same name as the tag,
# otherwise it will be named 'latest'
RELEASE_NAME="`git tag --points-at HEAD`"
[ -z $RELEASE_NAME ] && RELEASE_NAME="latest"
[[ $RELEASE_NAME = "latest" ]] && IS_PRE_RELEASE="true" || IS_PRE_RELEASE="false"
# set env and call cross-build.sh
export OPENOCD_TAG=$OPENOCD_TAG
export OPENOCD_SRC=$PWD
export OPENOCD_CONFIG=""
mkdir -p $BUILD_DIR &&  cd $BUILD_DIR
bash $OPENOCD_SRC/contrib/cross-build.sh $HOST
# add missing dlls
cd $HOST-root/usr
cp `$HOST-gcc --print-file-name=libwinpthread-1.dll` ./bin/
cp `$HOST-gcc --print-file-name=libgcc_s_sjlj-1.dll` ./bin/
# prepare the artifact
ARTIFACT="openocd-${OPENOCD_TAG}-${HOST}.tar.gz"
tar -czf $ARTIFACT *
#echo "RELEASE_NAME=$RELEASE_NAME" >> $GITHUB_ENV
#echo "IS_PRE_RELEASE=$IS_PRE_RELEASE" >> $GITHUB_ENV
#echo "ARTIFACT_PATH=$PWD/$ARTIFACT" >> $GITHUB_ENV
ARTIFACT_PATH=$PWD/$ARTIFACT
cd $SRC_DIR