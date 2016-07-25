#!/bin/bash
# Author: Alexander Barth, 2013-2015
#
# Install octave and most dependencies.
# openblas, arpack, suitesparse, qrupdate, qhull, glpk, fftw, HDF5, FLTK, 
# readline, gnuplot, cURL, PCRE, freetype, expat, netcdf, graphicsmagick, 
# pstoedit, epstool, transfig, llvm, gl2ps, metis, octave,
#
# octave-forge packages
# general miscellaneous optim struct statistics io octcdf optiminterp netcdf 
# ncarray parallel
#
# What is not installed:
#
# qt4 (Red Hat: qt-devel)
# QScintilla  (Red Hat: qscintilla-devel) -> refuses to install in custom prefix
# java
#
# Issues with fontconfig
# http://modb.oce.ulg.ac.be/mediawiki/index.php/Octave#fontconfig
# Problem goes away if one installs fontconfig-devel, instead of compiling from source.


# Notes for nic4:
# For MKL, the env. variable MKL and INTEL_CC_HOME must be defined:
# e.g. 
# export MKL=/cm/shared/apps/intel/composer_xe/2013_sp1.1.106/mkl/lib/intel64
# export INTEL_CC_HOME=/cm/shared/apps/intel/composer_xe/2013_sp1.1.106
# export LD_LIBRARY_PATH="$INTEL_CC_HOME/compiler/lib/intel64:$LD_LIBRARY_PATH"
#
# Do not load the module. Just set the two variables, otherwise suitesparse will fail.
# Load also java module e.g.
#
# module load java/jdk1.7.0_51
# module load gcc/4.8.1
#
# then
# ~/matlab/bin/install_octave.sh --blas MKL  --separate no --download yes --postfix -mkl-$(date +%Y%m%d) 2>&1 | tee install.log
#
# The following environement variable must be defined to run octave (if the option seprate was no during the installation)
#
# # install directory, e.g.  /home/ulg/gher/abarth/local/gcc-4.8.1-mkl-20140814
# BASEDIR=... 
# export PATH="$BASEDIR/bin:$PATH"
# export LD_LIBRARY_PATH="$BASEDIR/lib:$MKL:$LD_LIBRARY_PATH"


set -e


USE_BLAS=openblas
CC=gcc
PICFLAG=-fPIC
FC=gfortran
FLIBS="-lgfortran"
JOBS=8
showpath=
dodownload=yes
separate=yes
separate=no
BASEDIR=
postfix=

if [ "$CC" == gcc ]; then
    CCVERSION=$(gcc -dumpversion)
fi


PATCHDIR=$HOME/matlab/bin/patch/

while [ "$1" != "" ]; do
    case $1 in
	"--blas")
            shift
            USE_BLAS=$1
            ;;
	"-j" | "--jobs")
	    shift
            JOBS=$1
            ;;
	"--showpath")
	    showpath=1
	    ;;
	"--download")
            shift
	    dodownload=$1
	    ;;
	"--separate")
            shift
	    separate=$1
	    ;;
	"-b" | "--basedir" | "--prefix")
	    shift
            BASEDIR=$1
            ;;
	"--postfix")
	    shift
            postfix=$1
            ;;
    esac
    shift
done

if [[ ! $BASEDIR ]]; then
    if [[ $separate == yes ]]; then
        BASEDIR=$HOME/opt/$CC-$CCVERSION$postfix
    else
        BASEDIR=$HOME/local/$CC-$CCVERSION$postfix
    fi
fi


function pkgprefix() {
    if [[ $separate == yes ]]; then
        echo $BASEDIR/$1-$2
    else
        echo $BASEDIR
    fi 
}

# source all package information
for f in pkgs/*; do 
  source $f; 
done

echo "install in $BASEDIR"



GCC_VERSION=4.8.2
GCC_URL=ftp://gcc.gnu.org/pub/gcc/releases/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz
GCC=$(pkgprefix gcc $GCC_VERSION)

BLAS_URL=http://www.netlib.org/blas/blas.tgz

OPENBLAS=$(pkgprefix OpenBLAS $OPENBLAS_VERSION)

GOTOBLAS2_VERSION=1.13
GOTOBLAS2_URL=http://www.tacc.utexas.edu/documents/13601/b58aeb8c-9d8d-4ec2-b5f1-5a5843b4d47b
GOTOBLAS2=$(pkgprefix GotoBLAS2 $GOTOBLAS_VERSION)

LAPACK_VERSION=3.5.0
LAPACK_URL=http://www.netlib.org/lapack/lapack-$LAPACK_VERSION.tgz
LAPACK=$(pkgprefix lapack $LAPACK_VERSION)

ARPACK_VERSION=96
ARPACK_URL=http://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.gz
ARPACK_PATCH_URL=http://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.gz
ARPACK=$(pkgprefix arpack $ARPACK_VERSION)

 #http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.0.2.tar.gz # incompatible with suitesparse 3.7 and  4.0.1
METIS_URL=http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/OLD/metis-4.0.3.tar.gz

SUITESPARSE_VERSION=3.7.1
# https://savannah.gnu.org/bugs/?func=detailitem&item_id=41209 -> fixed for octave 3.8.1 (supposely)
SUITESPARSE_VERSION=4.2.1
SUITESPARSE_URL=http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-$SUITESPARSE_VERSION.tar.gz

SUITESPARSE=$(pkgprefix suitesparse $SUITESPARSE_VERSION)

# http://www.fftw.org/download.html
FFTW_VERSION=3.3.4
FFTW_URL=ftp://ftp.fftw.org/pub/fftw/fftw-$FFTW_VERSION.tar.gz
FFTW=$(pkgprefix fftw $FFTW_VERSION)

# http://www.qhull.org/download/
QHULL_VERSION=2012.1
QHULL_URL=http://www.qhull.org/download/qhull-$QHULL_VERSION-src.tgz
QHULL=$(pkgprefix qhull $QHULL_VERSION)

# http://www.hdfgroup.org/HDF5/

HDF5_VERSION=1.8.17
HDF5_URL=http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-$HDF5_VERSION/src/hdf5-$HDF5_VERSION.tar.gz
HDF5=$(pkgprefix hdf5 $HDF5_VERSION)

# http://ftp.gnu.org/gnu/glpk/
GLPK_VERSION=4.52 # incompatible
GLPK_VERSION=4.46
GLPK_VERSION=4.54
GLPK_URL=http://ftp.gnu.org/gnu/glpk/glpk-$GLPK_VERSION.tar.gz
GLPK=$(pkgprefix glpk $GLPK_VERSION)

# http://www.gnuplot.info/download.html
GNUPLOT_VERSION=5.0.4
GNUPLOT_URL=http://downloads.sourceforge.net/gnuplot/gnuplot-$GNUPLOT_VERSION.tar.gz
GNUPLOT=$(pkgprefix gnuplot $GNUPLOT_VERSION)

FLTK_VERSION=1.3.2
FLTK_URL=http://fltk.org/pub/fltk/$FLTK_VERSION/fltk-$FLTK_VERSION-source.tar.gz
FLTK=$(pkgprefix fltk $FLTK_VERSION)

# http://www.unidata.ucar.edu/downloads/netcdf/index.jsp
NETCDF_VERSION=4.3.3.1
NETCDF_FORTRAN_VERSION=4.4.2
NETCDF_URL=http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-$NETCDF_VERSION.tar.gz
NETCDF=$(pkgprefix netcdf $NETCDF_VERSION)

QRUPDATE_VERSION=1.1.2
QRUPDATE_URL=http://downloads.sourceforge.net/project/qrupdate/qrupdate/1.2/qrupdate-$QRUPDATE_VERSION.tar.gz
QRUPDATE=$(pkgprefix qrupdate $QRUPDATE_VERSION)

# http://curl.haxx.se/download.html
CURL_VERSION=7.50.0
CURL_URL=http://curl.haxx.se/download/curl-$CURL_VERSION.tar.gz
CURL=$(pkgprefix curl $CURL_VERSION)

PCRE_VERSION=8.36
PCRE_URL=http://sourceforge.net/projects/pcre/files/pcre/$PCRE_VERSION/pcre-$PCRE_VERSION.tar.gz
PCRE=$(pkgprefix pcre $PCRE_VERSION)

FREETYPE_VERSION=2.4.12
FREETYPE_URL=http://download.savannah.gnu.org/releases/freetype/freetype-$FREETYPE_VERSION.tar.gz
FREETYPE=$(pkgprefix freetype $FREETYPE_VERSION)

READLINE_VERSION=6.3
READLINE_URL=ftp://ftp.cwru.edu/pub/bash/readline-$READLINE_VERSION.tar.gz
READLINE=$(pkgprefix readline $READLINE_VERSION)

TEXINFO_VERSION=4.13
TEXINFO_URL=http://ftp.gnu.org/gnu/texinfo/texinfo-$TEXINFO_VERSION.tar.gz
TEXINFO=$(pkgprefix texinfo $TEXINFO_VERSION)

EXPAT_VERSION=2.1.0
EXPAT_URL=http://downloads.sourceforge.net/project/expat/expat/$EXPAT_VERSION/expat-$EXPAT_VERSION.tar.gz
EXPAT=$(pkgprefix expat $EXPAT_VERSION)

FONTCONFIG_VERSION=2.10.2
FONTCONFIG_URL=http://www.freedesktop.org/software/fontconfig/release/fontconfig-$FONTCONFIG_VERSION.tar.bz2
FONTCONFIG=$(pkgprefix fontconfig $FONTCONFIG_VERSION)

GRAPHICSMAGICK_VERSION=1.3.24
GRAPHICSMAGICK_URL=http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/$GRAPHICSMAGICK_VERSION/GraphicsMagick-$GRAPHICSMAGICK_VERSION.tar.gz
GRAPHICSMAGICK=$(pkgprefix graphicsmagick $GRAPHICSMAGICK_VERSION)

PSTOEDIT_VERSION=3.62
PSTOEDIT_URL=http://sourceforge.net/projects/pstoedit/files/pstoedit/$PSTOEDIT_VERSION/pstoedit-$PSTOEDIT_VERSION.tar.gz
PSTOEDIT=$(pkgprefix pstoedit $PSTOEDIT_VERSION)

LLVM_VERSION=3.3
LLVM_URL=http://llvm.org/releases/$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.gz
LLVM=$(pkgprefix llvm $LLVM_VERSION)

GL2PS_VERSION=1.3.8
GL2PS_URL=http://geuz.org/gl2ps/src/gl2ps-$GL2PS_VERSION.tgz
GL2PS=$(pkgprefix gl2ps $GL2PS_VERSION)

EPSTOOL_VERSION=3.08
# currently down
EPSTOOL_URL=http://mirror.cs.wisc.edu/pub/mirrors/ghost/ghostgum/epstool-$EPSTOOL_VERSION.tar.gz
EPSTOOL_URL=http://pkgs.fedoraproject.org/repo/pkgs/epstool/epstool-3.08.tar.gz/465a57a598dbef411f4ecbfbd7d4c8d7/epstool-3.08.tar.gz
EPSTOOL=$(pkgprefix epstool $EPSTOOL_VERSION)


TRANSFIG_VERSION=3.2.5e
TRANSFIG_URL=https://downloads.sourceforge.net/project/mcj/mcj-source/transfig.$TRANSFIG_VERSION.tar.gz
TRANSFIG=$(pkgprefix transfig $TRANSFIG_VERSION)


TIFF_VERSION=4.0.3
TIFF_URL=ftp://ftp.remotesensing.org/libtiff/tiff-$TIFF_VERSION.tar.gz
TIFF=$(pkgprefix tiff $TIFF_VERSION)

UNITS_VERSION=2.11
UNITS_URL=http://ftp.gnu.org/gnu/units/units-$UNITS_VERSION.tar.gz
UNITS=$(pkgprefix units $UNITS_VERSION)

OCTAVE_VERSION=3.6.4
OCTAVE_VERSION=3.8.1
OCTAVE_VERSION=3.8.2
OCTAVE_VERSION=4.0.3
OCTAVE_URL=ftp://ftp.gnu.org/gnu/octave/octave-$OCTAVE_VERSION.tar.xz
#OCTAVE_VERSION=4.0.0-rc2
#OCTAVE_URL=ftp://alpha.gnu.org/gnu/octave/octave-$OCTAVE_VERSION.tar.xz


OCTAVE=$(pkgprefix octave $OCTAVE_VERSION)


if [ $USE_BLAS == gotoblas ]; then   
    echo "using gotoblas"
    BLAS=$OPENBLAS
    BLAS_LIBDIR="$BLAS/lib"
    # full linking options for BLAS
    BLAS_LIB="-L$BLAS_LIBDIR -lblas $FLIBS -lpthread"
    LAPACK_LIB="-L$LAPACK/lib -llapack"  
    export GOTO_NUM_THREADS=1
fi


if [ $USE_BLAS == openblas ]; then
    echo "using openblas"
    BLAS=$OPENBLAS
    BLAS_LIBDIR="$BLAS/lib"
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

#FFLAGS=-fdefault-integer-8

function download() {
    wget --timestamping $METIS_URL
    wget --timestamping $SUITESPARSE_URL
    if [ $USE_BLAS == openblas ]; then   
    wget -O OpenBLAS-$OPENBLAS_VERSION.tar.gz $OPENBLAS_URL
    fi
    #wget -O GotoBLAS2-$GOTOBLAS_VERSION.tar.gz $GOTOBLAS2_URL
    wget --timestamping $LAPACK_URL
    wget --timestamping $QHULL_URL
    wget --timestamping $ARPACK_URL
    wget --timestamping $ARPACK_PATCH_URL
    wget --timestamping $QRUPDATE_URL
}

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


function sucessful() {
  local prefix=$1
  local name=$2

  
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

function build() {
    local configArgs=
    local makeArgs=
    local packageDir=
    local check=no
    local buildsystem=gnu  # gnu (for configure) or cmake

    while [ "$1" != "" ]; do
	case $1 in
	    "--package")
		shift
		package="$1"
		;;
	    "--name")
		shift
		name="$1"
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
	    "--buildsystem")
		shift
		buildsystem="$1"
		;;
	esac
	shift
    done

    if sucessful $prefix $name; then
	echo "$name already present in $prefix"
	moduleload $prefix
	return
    fi

    if [[ $package == ftp* ]] || [[ $package == http* ]]; then
	file=$(basename $package)

	if [ -f $file ]; then
            echo "$package already downloaded"
	else
            echo download $package
            wget $package
	fi
    else
	file=$package
    fi

    if [[ -z $packageDir ]]; then
	packageDir=$(echo $file | sed 's/.tar.*//')
    fi

    rm -Rf $packageDir
    tar -xf $file
    cd $packageDir

    if [ $buildsystem == gnu ]; then
      ./configure --prefix=$prefix  $configArgs | tee configure.log
    else
      cmake -DCMAKE_INSTALL_PREFIX:PATH=$prefix | tee cmake.log
    fi

    make -j $JOBS $makeArgs | tee make.log

    if [[ $check == yes ]]; then
	make check | tee make_check.log
    fi

    make install | tee make_install.log
    cd ..

    moduleload $prefix
}



function GOTOBLAS_build() {
    if sucessful $GOTOBLAS gotoblas; then
	echo "GOTOBLAS already present in $GOTOBLAS/lib"
	moduleload $GOTOBLAS
	return
    fi

    tar xf GotoBLAS2-1.13.tar.gz
    cd GotoBLAS2
# may need two makes (-l -l)
    make FC=$FC BINARY64=1 USE_THREAD=1 TARGET=NEHALEM | tee make.log
 #make PREFIX=$GOTOBLAS install

    mkdir -p $GOTOBLAS/lib
    mv libgoto2*  $GOTOBLAS/lib
    cd  $GOTOBLAS/lib
    ln -s libgoto2.a libblas.a
    ln -s libgoto2.so libblas.so
    cd -
    cd ..

    moduleload $GOTOBLAS
}

function BLAS_build() {
    if sucessful $BLAS blas; then
	echo "reference BLAS already present in $BLAS/lib"
	moduleload $BLAS
	return
    fi

    tar -xzf blas.tgz
    cd BLAS
    make FORTRAN=$FC OPTS="$PICFLAG -O3 $FFLAGS" BLASLIB=libblas.a

    mkdir -p $BLAS/lib
    cp libblas.a $BLAS/lib
    cd ..

    moduleload $BLAS
}

function LAPACK_build() {
    if sucessful $LAPACK lapack; then
	echo "LAPACK already present in $LAPACK/lib"
	moduleload $LAPACK
	return
    fi

    tar -zxf lapack-$LAPACK_VERSION.tgz
    cd lapack-$LAPACK_VERSION
    cp make.inc.example  make.inc
    make FORTRAN=$FC LOADER=$FC OPTS="-funroll-all-loops -O3 $PICFLAG $FFLAGS" NOOPT="$PICFLAG" PLAT=  \
	LAPACKLIB=liblapack.a  BLASLIB=$BLAS/lib/libblas.a TIMER=INT_ETIME  lapacklib | tee make.log

    mkdir -p $LAPACK/lib
    mv liblapack.a $LAPACK/lib/
    make clean
    cd ..

    moduleload $LAPACK
}

function ARPACK_build() {
    if sucessful $ARPACK arpack; then
	echo "ARPACK already present in $ARPACK/lib"
	moduleload $ARPACK
	return
    fi

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


    mkdir -p $ARPACK/lib
    cp libarpack.a $ARPACK/lib
    cd ..

    moduleload $ARPACK
}

function METIS5_build() {
    cd metis-5.0.2
    echo "set (CMAKE_INSTALL_PREFIX $SUITESPARSE )" >> CMakeLists.txt
    make config
    make install
    moduleload $SUITESPARSE
}

function QHULL_build() {
    if sucessful $QHULL qhull; then
	echo "QHULL already present in $QHULL/lib"
	moduleload $QHULL
	return
    fi

    tar -zxf qhull-$QHULL_VERSION-src.tgz
    cd qhull-$QHULL_VERSION
#  cd build
#  cmake -DCMAKE_INSTALL_PREFIX:PATH=$QHULL ..
#  make
#  cd ..
    make | tee make.log
    make DESTDIR=$QHULL install | tee make_install.log
    cd ..

    moduleload $QHULL
}

function SUITESPARSE_build() {
    if sucessful $SUITESPARSE cholmod; then
	echo "SUITESPARSE already present in $SUITESPARSE/lib"
	moduleload $SUITESPARSE
	return
    fi

    mkdir -p $SUITESPARSE/{lib,include/suitesparse}

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
    cp {AMD,BTF,CAMD,CCOLAMD,CHOLMOD,COLAMD,CXSparse,UMFPACK}/Lib/lib*a metis-4.0.3/libmetis.a $SUITESPARSE/lib/
    cp {AMD,BTF,CAMD,CCOLAMD,CHOLMOD,COLAMD,CXSparse,UMFPACK}/Include/*h $SUITESPARSE/include/suitesparse

    if [ -e UFconfig/UFconfig.mk ]; then
      cp UFconfig/*.h $SUITESPARSE/include/suitesparse
    else
      cp SuiteSparse_config/*.h $SUITESPARSE/include/suitesparse
      cp SuiteSparse_config/libsuitesparseconfig.a $SUITESPARSE/lib/
    fi 

    cd ..

    moduleload $SUITESPARSE
}


function EPSTOOL_build() {
    if sucessful $EPSTOOL epstool; then
	echo "epstool already present in $EPSTOOL/bin"
	moduleload $EPSTOOL
	return
    fi

    wget --timestamping $EPSTOOL_URL
    tar xf epstool-$EPSTOOL_VERSION.tar.gz 
    cd epstool-$EPSTOOL_VERSION
    make | tee make.log
    make install EPSTOOL_ROOT=$EPSTOOL  | tee make_install.log
    cd ..
}

function TRANSFIG_build() {
    if sucessful $TRANSFIG fig2dev; then
	echo "fig2dev already present in $TRANSFIG/bin"
	moduleload $TRANSFIG
	return
    fi

    wget --timestamping $TRANSFIG_URL
    rm -Rf transfig.$TRANSFIG_VERSION/
    tar xf transfig.$TRANSFIG_VERSION.tar.gz 
    cd transfig.$TRANSFIG_VERSION/
    patch -p1 -u < $PATCHDIR/transfig-1-configure.patch 
    chmod +x ./configure
    ./configure --prefix $TRANSFIG | tee configure.log
    make | tee make.log
    make install | tee make_install.log
    cd ..
}

function NETCDF_FORTRAN_build() {

    tar zxf netcdf-fortran-$NETCDF_FORTRAN_VERSION.tar.gz
    cd netcdf-fortran-$NETCDF_VERSION
    ./configure FC=$FC CPPFLAGS="-I$HDF5/include"  LDFLAGS="-L$HDF5/lib" --prefix=$NETCDF
    make -j $JOBS | tee make.log
    make check | tee make_check.log
    make install | tee make_install.log
    cd .. 
}

function QRUPDATE_build() {
    if sucessful $QRUPDATE qrupdate; then
	echo "QRUPDATE already present in $QRUPDATE/lib"
	moduleload $QRUPDATE
	return
    fi

    tar zxf qrupdate-$QRUPDATE_VERSION.tar.gz
    cd qrupdate-$QRUPDATE_VERSION

    echo "FC=$FC" >> Makeconf
    echo "FFLAGS=$FFLAGS" >> Makeconf
    echo "BLAS=$BLAS_LIB" >> Makeconf
    echo "LAPACK=$LAPACK_LIB" >> Makeconf

    make -j $JOBS lib | tee make.log
    make test     | tee make_test.log
    make PREFIX=$QRUPDATE install
    cd .. 

    moduleload $QRUPDATE
}


function OCTAVE_FORGE_build() {    
    $OCTAVE/bin/octave --no-init-file --eval 'pkg install -global -forge -verbose general miscellaneous optim struct statistics io octcdf optiminterp netcdf ncarray'
    $OCTAVE/bin/octave --no-init-file --eval 'pkg install -global -forge -verbose nan'
    $OCTAVE/bin/octave --no-init-file --eval 'pkg install -global -forge -verbose parallel'
}

function all_build() {

    mkdir -p $BASEDIR

    if [[ $separate == no ]]; then
	PKG_CONFIG_PATH="$BASEDIR/lib/pkgconfig:$PKG_CONFIG_PATH"
	PATH="$BASEDIR/bin:$PATH"
        CPPFLAGS="-I$BASEDIR/include $CPPFLAGS"
	LDFLAGS="-L$BASEDIR/lib $LDFLAGS"
	LD_LIBRARY_PATH="$BASEDIR/lib:$LD_LIBRARY_PATH"
        export PATH PKG_CONFIG_PATH LD_LIBRARY_PATH LDFLAGS CPPFLAGS
    fi

    if [[ $dodownload == yes ]]; then
	download
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
	--configArgs "FC=$FC CPPFLAGS=-I$HDF5/include  LDFLAGS=-L$HDF5/lib"

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

if [[ ! -z $showpath ]]; then
    echo "export PATH=\"$NETCDF/bin:\$PATH\""
    echo "export LD_LIBRARY_PATH=\"$BLAS_LIBDIR:$SUITESPARSE/lib:$FFTW/lib:$QHULL/lib:$HDF5/lib:$GLPK/lib:$PCRE/lib:$NETCDF/lib:$QRUPDATE/lib:\$LD_LIBRARY_PATH\""
else
#    all_build

    echo "PATH=$PATH"
    echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

    PACKAGES=(openblas lapack)
    
    for name in "${PACKAGES[@]}"; do
	echo $name
        
        # upcase name
        NAME=$(echo $name | tr '[:upper:]' '[:lower:]' | tr - _)
        if [ type -t ${NAME}_build ]; then
            # call specific build script
            ${NAME}_build
        else
            # call generic build script
            build --package ${${NAME}_URL} --prefix ${NAME}_ --name llvm --check yes \
	--configArgs "--enable-shared"
            
        done
    done

fi