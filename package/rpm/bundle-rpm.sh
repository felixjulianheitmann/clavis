BINARIES_DIR=$1
VERSION=$2
ARCH=$3

VERSION=${VERSION//-/+}

PKG_DIR=package/rpm/rpmbuild
NAME=clavis
PKG_TITLE=${NAME}-${VERSION}
PKG_TITLE_ARCH=${NAME}-${VERSION}-${ARCH}

rm -rf $PKG_DIR/SOURCES/app

mkdir -p $PKG_DIR/BUILD
mkdir -p $PKG_DIR/SOURCES/app
mkdir -p $PKG_DIR/RPMS
mkdir -p $PKG_DIR/SPECS
mkdir -p $PKG_DIR/SRPMS

# mkdir $PKG_TITLE
# mv $BINARIES_DIR $PKG_TITLE
# tar --create --file $PKG_TITLE.tar.gz $PKG_TITLE
# mv $PKG_TITLE.tar.gz $PKG_DIR/BUILD
cp -r $BINARIES_DIR/* $PKG_DIR/SOURCES/app

# Fix RPaths which are not suited for rpm builds:
# https://stackoverflow.com/questions/69828408/is-it-possible-to-generate-linux-rpm-packages-from-flutter-linux-app
patchelf --set-rpath '$ORIGIN' $PKG_DIR/SOURCES/app/lib/libflutter_secure_storage_linux_plugin.so
patchelf --set-rpath '$ORIGIN' $PKG_DIR/SOURCES/app/lib/liburl_launcher_linux_plugin.so
patchelf --set-rpath '$ORIGIN' $PKG_DIR/SOURCES/app/lib/libwindow_size_plugin.so


rpmbuild \
    --define="_topdir `pwd`/package/rpm/rpmbuild" \
    --define="clavis_arch $ARCH" \
    --define="clavis_version $VERSION" \
    -bb package/rpm/rpmbuild/SPECS/clavis.spec
