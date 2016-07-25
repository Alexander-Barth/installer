#!/bin/bash
# Author: Alexander Barth, 2013-2016
#
# Install

set -e


USE_BLAS=openblas
CC=gcc
PICFLAG=-fPIC
FC=gfortran
FLIBS="-lgfortran"
JOBS=4
showpath=
dodownload=yes
separate=no
PREFIX=
postfix=

if [ "$CC" == gcc ]; then
    CCVERSION=$(gcc -dumpversion)
fi


PATCHDIR=$HOME/matlab/bin/patch/

while [[ $# -gt 1 ]]; do
    key="$1"

    case $1 in
	--blas)
            shift
            USE_BLAS=$1
            ;;
	--blas=*)
            USE_BLAS="${key#*=}"
            ;;
	-j | --jobs)
	    shift
            JOBS="$1"
            ;;
        -j=*|--jobs=*)
            JOBS="${key#*=}"
            ;;
	--showpath)
	    showpath=1
	    ;;
	--download)
            shift
	    dodownload=$1
	    ;;
	--download=*)
	    dodownload="${key#*=}"
	    ;;
	--separate)
            shift
	    separate=$1
	    ;;
	--separate=*)
	    separate="${key#*=}"
	    ;;
	-b | --basedir | --prefix)
	    shift
            PREFIX=$1
            ;;
        -p=*|--prefix=*)
            PREFIX="${key#*=}"
            ;;
        --fc|--fortran-compiler)
            shift
            FC="$1"
            ;;
        --fc=*|--fortran-compiler=)
            FC="${key#*=}"
            ;;
        --cc|--c-compiler)
            shift
            CC="$1"
            ;;
        --cc=*|--c-compiler=)
            CC="${key#*=}"
            ;;
	--postfix)
	    shift
            postfix=$1
            ;;
	--postfix=*)
            postfix="${key#*=}"
            ;;
        *)
	    break
            # unknown option

    esac
    shift
done

PACKAGES=( "$@" )


if [[ ! $PREFIX ]]; then
    if [[ $separate == yes ]]; then
        PREFIX=$HOME/opt/$CC-$CCVERSION$postfix
    else
        PREFIX=$HOME/local/$CC-$CCVERSION$postfix
    fi
fi

# print message of a given importance

function message() {
    local importance=$1
    local message=$2

    if (( $importance < 1 )); then
        # ignore
        return
    fi

    if [ $importance == 3 ]; then
        echo -e "\e[32m$message\e[0m"
    elif [ $importance == 2 ]; then
        echo -e "\e[34m$message\e[0m"
    else
        echo $message
    fi

}


function pkgprefix() {
    if [[ $separate == yes ]]; then
        echo $PREFIX/$1-$2
    else
        echo $PREFIX
    fi 
}

# source all package information
#for f in pkgs/*; do 
#  source $f; 
#done

message 2 "Request to install ${PACKAGES} in $PREFIX"


GCC_VERSION=4.8.2
GCC_URL=ftp://gcc.gnu.org/pub/gcc/releases/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz

BLAS_VERSION=3.6.0
BLAS_URL=http://www.netlib.org/blas/blas-$BLAS_VERSION.tgz

LAPACK_VERSION=3.5.0
LAPACK_URL=http://www.netlib.org/lapack/lapack-$LAPACK_VERSION.tgz

ARPACK_VERSION=96
ARPACK_URL=http://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.gz
ARPACK_PATCH_URL=http://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.gz

 #http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.0.2.tar.gz # incompatible with suitesparse 3.7 and  4.0.1
METIS_URL=http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/OLD/metis-4.0.3.tar.gz

SUITESPARSE_VERSION=4.2.1
SUITESPARSE_URL=http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-$SUITESPARSE_VERSION.tar.gz

# http://www.fftw.org/download.html
FFTW_VERSION=3.3.4
FFTW_URL=ftp://ftp.fftw.org/pub/fftw/fftw-$FFTW_VERSION.tar.gz

# http://www.qhull.org/download/
QHULL_VERSION=2012.1
QHULL_URL=http://www.qhull.org/download/qhull-$QHULL_VERSION-src.tgz

# http://www.hdfgroup.org/HDF5/
HDF5_VERSION=1.8.17
HDF5_URL=http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-$HDF5_VERSION/src/hdf5-$HDF5_VERSION.tar.gz

# http://ftp.gnu.org/gnu/glpk/
GLPK_VERSION=4.54
GLPK_URL=http://ftp.gnu.org/gnu/glpk/glpk-$GLPK_VERSION.tar.gz

# http://www.gnuplot.info/download.html
GNUPLOT_VERSION=5.0.4
GNUPLOT_URL=http://downloads.sourceforge.net/gnuplot/gnuplot-$GNUPLOT_VERSION.tar.gz

FLTK_VERSION=1.3.2
FLTK_URL=http://fltk.org/pub/fltk/$FLTK_VERSION/fltk-$FLTK_VERSION-source.tar.gz

# http://www.unidata.ucar.edu/downloads/netcdf/index.jsp
NETCDF_VERSION=4.3.3.1
NETCDF_FORTRAN_VERSION=4.4.2
NETCDF_URL=http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-$NETCDF_VERSION.tar.gz

QRUPDATE_VERSION=1.1.2
QRUPDATE_URL=http://downloads.sourceforge.net/project/qrupdate/qrupdate/1.2/qrupdate-$QRUPDATE_VERSION.tar.gz

# http://curl.haxx.se/download.html
CURL_VERSION=7.50.0
CURL_URL=http://curl.haxx.se/download/curl-$CURL_VERSION.tar.gz

PCRE_VERSION=8.36
PCRE_URL=http://sourceforge.net/projects/pcre/files/pcre/$PCRE_VERSION/pcre-$PCRE_VERSION.tar.gz

FREETYPE_VERSION=2.4.12
FREETYPE_URL=http://download.savannah.gnu.org/releases/freetype/freetype-$FREETYPE_VERSION.tar.gz

READLINE_VERSION=6.3
READLINE_URL=ftp://ftp.cwru.edu/pub/bash/readline-$READLINE_VERSION.tar.gz

TEXINFO_VERSION=4.13
TEXINFO_URL=http://ftp.gnu.org/gnu/texinfo/texinfo-$TEXINFO_VERSION.tar.gz

EXPAT_VERSION=2.1.0
EXPAT_URL=http://downloads.sourceforge.net/project/expat/expat/$EXPAT_VERSION/expat-$EXPAT_VERSION.tar.gz

FONTCONFIG_VERSION=2.10.2
FONTCONFIG_URL=http://www.freedesktop.org/software/fontconfig/release/fontconfig-$FONTCONFIG_VERSION.tar.bz2

GRAPHICSMAGICK_VERSION=1.3.24
GRAPHICSMAGICK_URL=http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/$GRAPHICSMAGICK_VERSION/GraphicsMagick-$GRAPHICSMAGICK_VERSION.tar.gz

PSTOEDIT_VERSION=3.62
PSTOEDIT_URL=http://sourceforge.net/projects/pstoedit/files/pstoedit/$PSTOEDIT_VERSION/pstoedit-$PSTOEDIT_VERSION.tar.gz

LLVM_VERSION=3.3
LLVM_URL=http://llvm.org/releases/$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.gz

GL2PS_VERSION=1.3.8
GL2PS_URL=http://geuz.org/gl2ps/src/gl2ps-$GL2PS_VERSION.tgz

EPSTOOL_VERSION=3.08
# currently down
EPSTOOL_URL=http://mirror.cs.wisc.edu/pub/mirrors/ghost/ghostgum/epstool-$EPSTOOL_VERSION.tar.gz
EPSTOOL_URL=http://pkgs.fedoraproject.org/repo/pkgs/epstool/epstool-3.08.tar.gz/465a57a598dbef411f4ecbfbd7d4c8d7/epstool-3.08.tar.gz


TRANSFIG_VERSION=3.2.5e
TRANSFIG_URL=https://downloads.sourceforge.net/project/mcj/mcj-source/transfig.$TRANSFIG_VERSION.tar.gz

TIFF_VERSION=4.0.3
TIFF_URL=ftp://ftp.remotesensing.org/libtiff/tiff-$TIFF_VERSION.tar.gz

UNITS_VERSION=2.11
UNITS_URL=http://ftp.gnu.org/gnu/units/units-$UNITS_VERSION.tar.gz

OCTAVE_VERSION=4.0.3
OCTAVE_URL=ftp://ftp.gnu.org/gnu/octave/octave-$OCTAVE_VERSION.tar.xz
#OCTAVE_VERSION=4.0.0-rc2
#OCTAVE_URL=ftp://alpha.gnu.org/gnu/octave/octave-$OCTAVE_VERSION.tar.xz




if [ $USE_BLAS == openblas ]; then
    echo "using openblas"
    BLAS=$OPENBLAS
    BLAS_LIBDIR="$BLAS_PREFIX/lib"
  # full linking options for BLAS
    BLAS_LIB="-L$BLAS_LIBDIR -lopenblas $FLIBS -lpthread"
    LAPACK_LIB="$BLAS_LIB"
    LAPACK_LIBDIR="$BLAS_LIBDIR"
fi

if [ $USE_BLAS == MKL ]; then
    echo "using MKL"
# intel MKL
#MKL=
    BLAS_LIBDIR="$MKL"
    LAPACK_LIBDIR="$MKL"

    #MKL_LIB="-Wl,--start-group -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -Wl,--end-group -liomp5 -lpthread"
    MKL_LIB="-L$MKL -Wl,--start-group -lmkl_gf_lp64 -lmkl_intel_thread -lmkl_core -Wl,--end-group -L$INTEL_CC_HOME/compiler/lib/intel64/ -liomp5 -lpthread"
    BLAS_LIB="$MKL_LIB"
    LAPACK_LIB="$MKL_LIB"
    export LD_LIBRARY_PATH="$MKL:$LD_LIBRARY_PATH"
fi


# make it visible
function moduleload() {
    local prefix=$1

    if [[ $separate == no ]]; then
        return;
    fi

    if [ -e $prefix/lib/pkgconfig ]; then
	PKG_CONFIG_PATH="$prefix/lib/pkgconfig:$PKG_CONFIG_PATH"
    fi

    if [ -d $prefix/bin ]; then
	PATH="$prefix/bin:$PATH"
    fi

    if [ -d $prefix/include ]; then
        CPPFLAGS="-I$prefix/include $CPPFLAGS"
    fi

    if [ -d $prefix/lib ]; then
	LDFLAGS="-L$prefix/lib $LDFLAGS"
	LD_LIBRARY_PATH="$prefix/lib:$LD_LIBRARY_PATH"
    fi

    export PATH PKG_CONFIG_PATH LD_LIBRARY_PATH LDFLAGS CPPFLAGS
}

# check if build what sucessful

function sucessful() {
  local prefix=$1
  local name=$2

  echo "prefix $prefix $name"
  echo "name $name"
  if [ $name == llvm ]; then
    # check if llvm was correctly compiled
    if [ -e $prefix/lib/libLLVMCore.a ]; then
      return 0;
    fi
  fi

  if [ -e $prefix/lib/lib$name.so ]; then
      return 0;
  fi

  if [ -e $prefix/lib/lib$name.a ]; then
      return 0;
  fi

  if [ -e $prefix/bin/$name ]; then
      return 0;
  fi

  return 1;
}


# build a generic package

function build() {
    local configArgs=
    local makeArgs=
    local makeInstallArgs=
    local packageDir=
    local check=no

    while [ "$1" != "" ]; do
	case $1 in
	    "--url")
		shift
		url="$1"
		;;
	    "--packagedir")
		shift
		packageDir="$1"
		;;
	    "--check")
		shift
		check="$1"
		;;
	    "--prefix")
		shift
		prefix="$1"
		;;
	    "--configArgs")
		shift
		configArgs="$1"
		;;
	    "--makeArgs")
		shift
		makeArgs="$1"
		;;
            "--makeInstallArgs")
                shift
                makeInstallArgs="$1"
                ;;
	esac
	shift
    done

    if [[ $url == ftp* ]] || [[ $url == http* ]]; then
	file=$(basename $url)

	if [ -f $file ]; then
            echo "$url already downloaded"
	else
            echo download $url
            wget $url
	fi
    else
	file=$url
    fi

    if [[ -z $packageDir ]]; then
	packageDir=$(echo $file | sed 's/.tar.*//')
    fi

    rm -Rf $packageDir
    tar -xf $file
    cd $packageDir

    if [ -x ./configure ]; then
        # gnu autotools
        ./configure --prefix=$prefix  $configArgs | tee configure.log        
    elif [ -r ./CMakeLists.txt ]; then
        # cmake
        cmake -DCMAKE_INSTALL_PREFIX:PATH=$prefix | tee cmake.log
    fi

    make -j $JOBS $makeArgs | tee make.log

    if [[ $check == yes ]]; then
	make check | tee make_check.log
    fi

    make install $makeInstallArgs | tee make_install.log
    cd ..
}


OPENBLAS_VERSION=0.2.18
OPENBLAS_URL=http://github.com/xianyi/OpenBLAS/tarball/v$OPENBLAS_VERSION

function OPENBLAS_build() {
         echo "instamm openblas $OPENBLAS_URL"
    wget -O OpenBLAS-$OPENBLAS_VERSION.tar.gz $OPENBLAS_URL

    tar -xzf OpenBLAS-$OPENBLAS_VERSION.tar.gz
    cd *OpenBLAS*/
# use threaded OPENBLAS
    make FC=$FC BINARY64=1 USE_THREAD=1 -j $JOBS | tee make.log

# disable threaded OPENBLAS
#    make FC=$FC BINARY64=1 USE_THREAD=0 -j $JOBS | tee make.log
    make PREFIX=$OPENBLAS_PREFIX install | tee make_install.log
    cd $OPENBLAS_PREFIX/lib
    ln -s libopenblas.a libblas.a
    ln -s libopenblas.so libblas.so
    cd - 
    cd ..
}



function BLAS_build() {
    wget --timestamping $BLAS_URL

    tar -xzf blas-$BLAS_VERSION.tgz
    cd BLAS-$BLAS_VERSION
    make FORTRAN=$FC OPTS="$PICFLAG -O3 $FFLAGS" BLASLIB=libblas.a

    mkdir -p $BLAS_PREFIX/lib
    cp libblas.a $BLAS_PREFIX/lib
    cd ..
}

function LAPACK_build() {
    wget --timestamping $LAPACK_URL

    tar -zxf lapack-$LAPACK_VERSION.tgz
    cd lapack-$LAPACK_VERSION
    cp make.inc.example  make.inc
    make FORTRAN=$FC LOADER=$FC OPTS="-funroll-all-loops -O3 $PICFLAG $FFLAGS" NOOPT="$PICFLAG" PLAT=  \
	LAPACKLIB=liblapack.a  BLASLIB=$BLAS_PREFIX/lib/libblas.a TIMER=INT_ETIME  lapacklib | tee make.log

    mkdir -p $LAPACK_PREFIX/lib
    mv liblapack.a $LAPACK_PREFIX/lib/
    make clean
    cd ..
}

function ARPACK_build() {
    wget --timestamping $ARPACK_URL
    wget --timestamping $ARPACK_PATCH_URL

    tar xzvf arpack96.tar.gz
    tar xzvf patch.tar.gz

    cd ARPACK
    patch -p0 < $PATCHDIR/ARPACK-second.patch
# make FC=$FC FFLAGS=-fPIC MAKE=/usr/bin/make home=$PWD ARPACKLIB=$PWD/libarpack.a lib | tee make.log

    make FC=$FC FFLAGS=-fPIC \
	MAKE=/usr/bin/make \
	home="$PWD" \
	ARPACKLIB="$PWD/libarpack.a" \
	LAPACKLIB="$LAPACK_LIB" \
	BLASLIB="$BLAS_LIB" \
	BLASdir="" \
	LAPACKdir="" \
	lib | tee make.log


    mkdir -p $ARPACK_PREFIX/lib
    cp libarpack.a $ARPACK_PREFIX/lib
    cd ..
}

function METIS5_build() {
    wget --timestamping $METIS_URL

    cd metis-5.0.2
    echo "set (CMAKE_INSTALL_PREFIX $SUITESPARSE )" >> CMakeLists.txt
    make config
    make install
}

function QHULL_build() {
    wget --timestamping $QHULL_URL

    tar -zxf qhull-$QHULL_VERSION-src.tgz
    cd qhull-$QHULL_VERSION
#  cd build
#  cmake -DCMAKE_INSTALL_PREFIX:PATH=$QHULL ..
#  make
#  cd ..
    make | tee make.log
    make DESTDIR=$QHULL install | tee make_install.log
    cd ..
}

function SUITESPARSE_build() {
    if sucessful $SUITESPARSE_PREFIX cholmod; then
	echo "SUITESPARSE already present in $SUITESPARSE_PREFIX/lib"
	moduleload $SUITESPARSE_PREFIX
	return
    fi

    wget --timestamping $SUITESPARSE_URL
    mkdir -p $SUITESPARSE_PREFIX/{lib,include/suitesparse}

    rm -Rf SuiteSparse 
    tar zxf SuiteSparse-$SUITESPARSE_VERSION.tar.gz   
    cd SuiteSparse/
    tar xzf ../metis-4.0.3.tar.gz

    if [ -e UFconfig/UFconfig.mk ]; then
	# old config file
	config=UFconfig/UFconfig.mk
    else
	# new config file
	config=SuiteSparse_config/SuiteSparse_config.mk
    fi

    echo "CC=$CC" >> $config
    echo "CFLAGS=$PICFLAG -O" >> $config
    echo "F77FLAGS=$PICFLAG -O" >> $config
    echo "BLAS=-L$BLAS_LIBDIR $BLAS_LIB" >> $config
    echo "LAPACK=-L$LAPACK_LIBDIR $LAPACK_LIB" >> $config
    echo "OPTFLAGS = -O2 $PICFLAG" >> metis-4.0.3/Makefile.in
    echo "CFLAGS = -O3 $PICFLAG" >> CXSparse/Lib/Makefile
    cd metis-4.0.3
    make AR="ar cr" RANLIB=ranlib | tee make.log
    cd ..
    make | tee make.log
    # install libamd.a libbtf.a libccolamd.a libcholmod.a libcolamd.a libcxsparse.a libumfpack.a libmetis.a 
    cp {AMD,BTF,CAMD,CCOLAMD,CHOLMOD,COLAMD,CXSparse,UMFPACK}/Lib/lib*a metis-4.0.3/libmetis.a $SUITESPARSE_PREFIX/lib/
    cp {AMD,BTF,CAMD,CCOLAMD,CHOLMOD,COLAMD,CXSparse,UMFPACK}/Include/*h $SUITESPARSE_PREFIX/include/suitesparse

    if [ -e UFconfig/UFconfig.mk ]; then
      cp UFconfig/*.h $SUITESPARSE_PREFIX/include/suitesparse
    else
      cp SuiteSparse_config/*.h $SUITESPARSE_PREFIX/include/suitesparse
      cp SuiteSparse_config/libsuitesparseconfig.a $SUITESPARSE_PREFIX/lib/
    fi 

    cd ..

}


function EPSTOOL_build() {
    wget --timestamping $EPSTOOL_URL
    tar -xf epstool-$EPSTOOL_VERSION.tar.gz 
    cd epstool-$EPSTOOL_VERSION
    make | tee make.log
    make install EPSTOOL_ROOT=$EPSTOOL_PREFIX  | tee make_install.log
    cd ..
}

function TRANSFIG_build() {
    wget --timestamping $TRANSFIG_URL
    rm -Rf transfig.$TRANSFIG_VERSION/
    tar xf transfig.$TRANSFIG_VERSION.tar.gz 
    cd transfig.$TRANSFIG_VERSION/
    patch -p1 -u < $PATCHDIR/transfig-1-configure.patch 
    chmod +x ./configure
    ./configure --prefix $TRANSFIG_PREFIX | tee configure.log
    make | tee make.log
    make install | tee make_install.log
    cd ..
}

function NETCDF_FORTRAN_build() {

    tar zxf netcdf-fortran-$NETCDF_FORTRAN_VERSION.tar.gz
    cd netcdf-fortran-$NETCDF_VERSION
    ./configure FC=$FC CPPFLAGS="-I$HDF5_PREFIX/include"  LDFLAGS="-L$HDF5_PREFIX/lib" --prefix=$NETCDF_FORTRAN_PREFIX
    make -j $JOBS | tee make.log
    make check | tee make_check.log
    make install | tee make_install.log
    cd .. 
}

function QRUPDATE_build() {
    wget --timestamping $QRUPDATE_URL

    tar zxf qrupdate-$QRUPDATE_VERSION.tar.gz
    cd qrupdate-$QRUPDATE_VERSION

    echo "FC=$FC" >> Makeconf
    echo "FFLAGS=$FFLAGS" >> Makeconf
    echo "BLAS=$BLAS_LIB" >> Makeconf
    echo "LAPACK=$LAPACK_LIB" >> Makeconf

    make -j $JOBS lib | tee make.log
    make test     | tee make_test.log
    make PREFIX=$QRUPDATE_PREFIX install
    cd .. 
}


function OCTAVE_FORGE_build() {    
    $OCTAVE_PREFIX/bin/octave --no-init-file --eval 'pkg install -global -forge -verbose general miscellaneous optim struct statistics io octcdf optiminterp netcdf ncarray'
    $OCTAVE_PREFIX/bin/octave --no-init-file --eval 'pkg install -global -forge -verbose nan'
    $OCTAVE_PREFIX/bin/octave --no-init-file --eval 'pkg install -global -forge -verbose parallel'
}

function all_build() {

    mkdir -p $PREFIX

    if [[ $separate == no ]]; then
	PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
	PATH="$PREFIX/bin:$PATH"
        CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
	LDFLAGS="-L$PREFIX/lib $LDFLAGS"
	LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
        export PATH PKG_CONFIG_PATH LD_LIBRARY_PATH LDFLAGS CPPFLAGS
    fi

    if [ $USE_BLAS == openblas ]; then   
	OPENBLAS_build
    fi

    if [ $USE_BLAS == refblas ]; then   
	BLAS_build
    fi

    if [ $USE_BLAS == gotoblas ]; then   
	GOTOBLAS_build
    fi

    if [ $USE_BLAS != openblas -a $USE_BLAS != MKL ]; then   
	echo "making lapack";
	LAPACK_build
    fi

    ARPACK_build
    SUITESPARSE_build
    QRUPDATE_build
    QHULL_build

    build --package $GLPK_URL --prefix $GLPK --name glpk \
	--configArgs "--enable-shared --disable-static"

    # FFTW must be build two times for the double and single precision interface
    # http://www.fftw.org/fftw2_doc/fftw_6.html#SEC69

    build --package $FFTW_URL --prefix $FFTW --name fftw3 \
	--configArgs "--enable-shared --disable-static --disable-fortran"

    rm -Rf fftw-$FFTW_VERSION
    build --package $FFTW_URL --prefix $FFTW --name fftw3f \
	--configArgs "--enable-shared --disable-static --disable-fortran --enable-single"

    build --package $HDF5_URL --prefix $HDF5 --name hdf5 \
	--configArgs "--enable-shared --disable-static --with-default-api-version=v16"

    build --package $FLTK_URL --prefix $FLTK --name fltk --packagedir fltk-$FLTK_VERSION \
	--configArgs "--enable-shared --disable-static"

    build --package $READLINE_URL --prefix $READLINE --name readline \
	--configArgs "--enable-shared --disable-static"

    build --package $TEXINFO_URL --prefix $TEXINFO --name makeinfo

    build --package $GNUPLOT_URL --prefix $GNUPLOT --name gnuplot

    build --package $CURL_URL --prefix $CURL --name curl

    build --package $PCRE_URL --prefix $PCRE --name pcre

    build --package $FREETYPE_URL --prefix $FREETYPE --name freetype

    build --package $EXPAT_URL --prefix $EXPAT --name expat

#    build --package $FONTCONFIG_URL --prefix $FONTCONFIG --name fontconfig

    build --package $NETCDF_URL --prefix $NETCDF  --name netcdf --check yes \
	--configArgs "FC=$FC CPPFLAGS=-I$HDF5_PREFIX/include  LDFLAGS=-L$HDF5_PREFIX/lib"

    build --package $TIFF_URL --prefix $TIFF --name tiff

    build --package $GRAPHICSMAGICK_URL --prefix $GRAPHICSMAGICK --name GraphicsMagick++ \
	--configArgs "--enable-shared --disable-static"

    build --package $PSTOEDIT_URL --prefix $PSTOEDIT --name pstoedit

    build --package $LLVM_URL --prefix $LLVM --name llvm --check yes \
	--configArgs "--enable-shared"

    build --package $GL2PS_URL --prefix $GL2PS --name gl2ps --buildsystem cmake \
        --packagedir gl2ps-$GL2PS_VERSION-source

    EPSTOOL_build
    TRANSFIG_build
    
    build --package $UNITS_URL --prefix $UNITS --name units

    export LIBS="-lmetis -lm -lpthread $BLAS_LIB $LAPACK_LIB $LIBS"
    build --package $OCTAVE_URL --prefix $OCTAVE --name octave --check yes --configArgs "--enable-jit"

    octave_forge_build
}


function setup_prefixes() {
    # loop over all packages

    for version in $(compgen -A variable | grep _VERSION); do
        NAME=${version%_VERSION}
        name=$(echo $NAME | tr '[:upper:]' '[:lower:]' | tr _ -)

        # get and set variable by indirection        
        # http://unix.stackexchange.com/a/68349
        #echo  $name ${!version}
        tmp=${NAME}_PREFIX

        # I have to use readonly here
        # http://stackoverflow.com/a/12158728

        readonly $tmp=$(pkgprefix $name ${!version})
        #echo "prefix" $name $(pkgprefix $name ${!version})
    done

    #echo "unit prefix inside ${UNITS_PREFIX}"
}



#    all_build

echo "PATH=$PATH"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

setup_prefixes

for name in "${PACKAGES[@]}"; do
    echo $name
    # upcase name
    NAME=$(echo $name | tr '[:lower:]' '[:upper:]' | tr - _)

    # get URL and PREFIX
    url=${NAME}_URL
    URL=${!url}

    prefix=${NAME}_PREFIX
    PREFIX=${!prefix}

    echo "prefix of $name is $PREFIX"
    if sucessful $PREFIX $name; then
        message 2 "$name is already present"
        moduleload $PREFIX
    else
        message 3 "installing $name"
        if type -t ${NAME}_build > /dev/null; then
            message 0 "call ${NAME}_build"
            # call specific build script
            ${NAME}_build
        else
            message 0 "call generic build script"

            build --package $URL --prefix $PREFIX --name $name \
              --configArgs "--enable-shared --disable-static"
        fi

        moduleload $PREFIX
    fi
done

