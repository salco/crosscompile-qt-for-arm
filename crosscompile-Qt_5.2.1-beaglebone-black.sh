#!/bin/sh -ex

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                         #
#  Copyright (C) 2015 Simon Stürz <simon.stuerz@guh.guru>                 #
#                                                                         #                                              #
#                                                                         #
#  This script is free software: you can redistribute it and/or modify    #
#  it under the terms of the GNU General Public License as published by   #
#  the Free Software Foundation, version 2 of the License.                #
#                                                                         #
#  This script is distributed in the hope that it will be useful,         #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of         #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           #
#  GNU General Public License for more details.                           #
#                                                                         #
#  You should have received a copy of the GNU General Public License      #
#  along with this script. If not, see <http://www.gnu.org/licenses/>.    #
#                                                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# the tutorial for this script can be found here: https://blog.guh.guru/tech/crosscompile-qt-5-2-1-for-bbb/

QT_VERSION_USE="5.7"
QT_SUBVERSION_USE="0"

CURRENT_DIR=`pwd`
#QT_SRCDIR="${CURRENT_DIR}/qt-everywhere-opensource-src-5.7.0"
QT_SRCDIR="${CURRENT_DIR}/qt-everywhere-opensource-src-${QT_VERSION_USE}.${QT_SUBVERSION_USE}"
QT_SRCFILE="${QT_SRCDIR}.tar.xz"
#QT_URL="http://download.qt.io/archive/qt/5.7/5.7.0/single/qt-everywhere-opensource-src-5.7.0.tar.xz"
QT_URL="http://download.qt.io/archive/qt/${QT_VERSION_USE}/${QT_VERSION_USE}.${QT_SUBVERSION_USE}/single/qt-everywhere-opensource-src-${QT_VERSION_USE}.${QT_SUBVERSION_USE}.tar.xz"
CC_DIR="${CURRENT_DIR}/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux"
CC_URL="http://releases.linaro.org/14.04/components/toolchain/binaries/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux.tar.xz"
CC_FILE="${CC_DIR}.tar.xz"
CC_PRE="${CC_DIR}/bin/arm-linux-gnueabihf-"
#PREFIX="${CURRENT_DIR}/Qt-5.7.0"
PREFIX="${CURRENT_DIR}/Qt-${QT_VERSION_USE}.${QT_SUBVERSION_USE}"
ROOTFS_DIR="${CURRENT_DIR}/rootfs"
LOG_DIR="${CURRENT_DIR}/logfiles"
NPROC=`nproc`

#uncomment to use my custom patch
#PATCH_SALCO=

## An exemple of condition
#echo "Patch salco "
#if [ -n "${PATCH_SALCO+xxx}" ]; then
#        echo "Activer"
#else
#	echo "Desactiver"
#fi
#exit

###############################################################
#clean up
# delete old log files
if [ -d ${LOG_DIR} ]; then
        sudo rm -rf ${LOG_DIR}
        mkdir ${LOG_DIR}
fi

# create the logfiles folder
if [ ! -d ${LOG_DIR} ]; then
        mkdir ${LOG_DIR}
fi

# delete qt src folder (old build stuff in it)
if [ -d ${QT_SRCDIR} ]; then
        sudo rm -rf ${QT_SRCDIR}
fi

# download qt source
if [ ! -f ${QT_SRCFILE} ]; then
	wget ${QT_URL}
fi

# extract qt source
if [ ! -d ${QT_SRCDIR} ]; then
	tar xf ${QT_SRCFILE}
fi

###############################################################
# download linaro cross compiler toolchain
if [ ! -f ${CC_FILE} ]; then
	wget -c ${CC_URL}
fi

# extract linaro cross compiler toolchain
if [ ! -d ${CC_DIR} ]; then
	tar xf ${CC_FILE}
fi

###############################################################
# extract the rootfs if it's missing
if [ ! -d ${ROOTFS_DIR} ]; then
        mkdir ${ROOTFS_DIR}
        ##sudo tar xf ${CURRENT_DIR}/rootfs.tar.bz2 -C ${ROOTFS_DIR}
	sudo tar xf ${CURRENT_DIR}/rootfs.tar.gz -C ${ROOTFS_DIR}
fi

###############################################################
# download script to create relative symlinks of the libs with absolute symlinks in the rootfs...
# Thx to https://gitorious.org/cross-compile-tools/cross-compile-tools.git (I offer the download because gitorious.org will be off soon)
if [ ! -f ${CURRENT_DIR}/fixQualifiedLibraryPaths ]; then
        wget http://guh.guru/downloads/scripts/fixQualifiedLibraryPaths
	chmod +x fixQualifiedLibraryPaths
fi

# ...fix the symlinks
sudo ./fixQualifiedLibraryPaths ${ROOTFS_DIR} ${CC_PRE}g++
##try to patch de Salco
if [ -n "${PATCH_SALCO+xxx}" ]; then
#info problematique
#DEFAULT_INCDIRS="/media/wm/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/arm-linux-gnueabihf/include/c++/4.8.3
#/media/wm/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/arm-linux-gnueabihf/include/c++/4.8.3/arm-linux-gnueabihf
#/media/wm/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/arm-linux-gnueabihf/include/c++/4.8.3/backward
#/media/wm/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/lib/gcc/arm-linux-gnueabihf/4.8.3/include
#/media/wm/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/lib/gcc/arm-linux-gnueabihf/4.8.3/include-fixed
#/media/wm/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/arm-linux-gnueabihf/include
#/media/wm/rootfs/usr/include
#/media/wm/rootfs/usr/include/arm-linux-gnueabihf
#"
#DEFAULT_LIBDIRS="/media/wm/rootfs/usr/lib
#/media/wm/rootfs/usr/lib/arm-linux-gnueabihf
#/media/wm/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/lib/gcc/arm-linux-gnueabihf/4.8.3
#/media/wm/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/lib/gcc/arm-linux-gnueabihf
#/media/wm/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/lib/gcc
#/media/wm/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux/arm-linux-gnueabihf/lib
#/media/wm/rootfs/lib/arm-linux-gnueabihf
#/media/wm/rootfs/lib
#"

	echo "AVANT: ${DEFAULT_LIBDIRS}"
	TEMP_DEFAULT_LIBDIRS="${DEFAULT_LIBDIRS} /usr/lib /usr/lib/arm-linux-gnueabihf /lib"

	DEFAULT_LIBDIRS=${TEMP_DEFAULT_LIBDIRS}
	echo "APRES: ${DEFAULT_LIBDIRS}"
fi

###############################################################
# create device...
cd ${QT_SRCDIR}/qtbase/mkspecs/devices/
cp -rv linux-beagleboard-g++ linux-beaglebone-g++
sed 's/softfp/hard/' <linux-beagleboard-g++/qmake.conf >linux-beaglebone-g++/qmake.conf

# ...and mkspec
cd ${QT_SRCDIR}/qtbase/mkspecs
cp -r linux-arm-gnueabi-g++/ linux-linaro-gnueabihf-g++/
TO_REPLACE="arm-linux-gnueabi-"
sed "s|${TO_REPLACE}|${CC_PRE}|g" <linux-arm-gnueabi-g++/qmake.conf >linux-linaro-gnueabihf-g++/qmake.conf

cd ${QT_SRCDIR}/qtbase/

###############################################################
# configure qtbase
if [ ! -d ${PREFIX} ]; then
	./configure \
	        -prefix ${PREFIX} \
		-extprefix ${PREFIX} \
	        -sysroot ${ROOTFS_DIR} \
	        -device linux-beaglebone-g++ \
		-xplatform linux-linaro-gnueabihf-g++ \
	        -device-option CROSS_COMPILE=${CC_PRE} \
		-release \
	        -silent \
	        -opensource \
	        -confirm-license \
	        -continue \
	        -v \
		-nomake examples \
		-nomake tests \
	        2>&1 | tee -a ${LOG_DIR}/qtbase-configure-log.txt \

		###############################################################
		#./configure \
		# The deployment directory, as seen on the target device
	        #-prefix ${PREFIX} \
		# The installation directory, as seen on the host machine.
		#-extprefix ${PREFIX} \
		# Sets <dir> as the target compiler's and qmake's sysroot and also sets pkg-config paths.
	        #-sysroot ${ROOTFS_DIR} \
		# Cross-compile for device <name> (experimental)
	        #-device linux-beaglebone-g++ \
		# The target platform when cross-compiling.
		#-xplatform linux-linaro-gnueabihf-g++ \
		# Add device specific options for the device mkspec (experimental)
	        #-device-option CROSS_COMPILE=${CC_PRE} \
		#-release \
	        #-silent \
	        #-opensource \
	        #-confirm-license \
	        #-continue \
	        #-v \
		#-nomake examples \
		#-nomake tests \
		#-qt-xcb \

		#manque:
		# -reduce-relocations \
                # -embedded arm
                # -platform linux-g++-64
                # -no-mmx
                # -no-3dnow
                # -no-sse
                # -no-sse2 -no-glib -no-cups -no-largefile 
                # -no-accessibility -no-openssl -no-gtkstyle -qt-mouse-pc 
                # -qt-mouse-linuxtp -qt-mouse-linuxinput -plugin-mouse-linuxtp
                # -plugin-mouse-pc -fast -little-endian -host-big-endian -no-pch
                # -no-sql-ibase -no-sql-mysql -no-sql-odbc -no-sql-psql -no-sql-sqlite
                # -no-sql-sqlite2 -no-webkit -no-qt3support -nomake examples
                # -nomake demos -nomake docs -nomake translations -qt-kbd-linuxinput
                #
	###############################################################
	# build qtbase
	make -j$NPROC 2>&1 | tee -a ${LOG_DIR}/qtbase-build-log.txt
	sudo make install
	cd ..
fi

# user our fresh compiled cross-qmake
QMAKE_CROSS="${PREFIX}/bin/qmake"
cd ${QT_SRCDIR}

###############################################################
# build qtgraphicaleffects
cd qtgraphicaleffects
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtgraphicaleffects-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtgraphicaleffects-make-log.txt
sudo make install
cd ..

###############################################################
# build qttools
cd qttools
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qttools-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qttools-make-log.txt
sudo make install
cd ..

###############################################################
# build qtscript
cd qtscript
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtscript-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtscript-make-log.txt
sudo make install
cd ..

###############################################################
# build qtserialport
cd qtserialport
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtserialport-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtserialport-make-log.txt
sudo make install
cd ..

###############################################################
# build qtsensors
cd qtsensors
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtsensors-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtsensors-make-log.txt
sudo make install
cd ..

###############################################################
# build qtimageformats
cd qtimageformats
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtimageformats-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtimageformats-make-log.txt
sudo make install
cd ..

###############################################################
# build qtsvg
cd qtsvg
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtsvg-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtsvg-make-log.txt
sudo make install
cd ..

###############################################################
# build qtactiveqt
cd qtactiveqt
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtactiveqt-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtactiveqt-make-log.txt
sudo make install
cd ..

###############################################################
# build qtxmlpatterns
cd qtxmlpatterns
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtxmlpatterns-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtxmlpatterns-make-log.txt
sudo make install
cd ..

###############################################################
# build qtdeclarative
cd qtdeclarative
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtdeclarative-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtdeclarative-make-log.txt
sudo make install
cd ..

###############################################################
# build qtquick1
#cd qtquick1
#${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtquick1-qmake-log.txt
#sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtquick1-make-log.txt
#sudo make install
#cd ..

###############################################################
# build qtx11extras
cd qtx11extras
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtx11extras-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtx11extras-make-log.txt
sudo make install
cd ..


###############################################################
# build qtquickcontrols
cd qtquickcontrols
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtquickcontrols-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtquickcontrols-make-log.txt
sudo make install
cd ..

###############################################################
# build qtmultimedia
cd qtmultimedia
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtmultimedia-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtmultimedia-make-log.txt
sudo make install
cd ..

###############################################################
# build qtconnectivity
cd qtconnectivity
${QMAKE_CROSS} 2>&1 | tee -a ${LOG_DIR}/qtconnectivity-qmake-log.txt
sudo make -j${NPROC} 2>&1 | tee -a ${LOG_DIR}/qtconnectivity-make-log.txt
sudo make install
cd ..



