#!/bin/sh
do_reg(){

    f=$A

    for g in `$FSLDIR/bin/imglob *_FA.*` ; do
            
    o=${g}_to_$f
    
    if [ ! -f ${o}_warp.msf ] ; then
        echo $o
        touch ${o}_warp.msf
        echo "$FSLDIR/bin/fsl_reg $g $f ${g}_to_$f -e -FA" >> .commands
    fi
    
    done
}

[ "$A" = "" ] && Usage

echo [`date`] [`hostname`] [`uname -a`] [`pwd`] [$0 $@] >> .tbsslog

/bin/rm -f FA/.commands

if [ $1 = -n ] ; then
    cd FA
    for f in `$FSLDIR/bin/imglob *_FA.*` ; do
    do_reg $f
    done
else
    if [ $1 = -T ] ; then
    TARGET=$FSLDIR/data/standard/FMRIB58_FA_1mm
    elif [ $1 = -t ] ; then
    TARGET=$2
    else
    Usage
    fi
    if [ `${FSLDIR}/bin/imtest $TARGET` = 0 ] ; then
    echo ""
    echo "Error: target image $TARGET not valid"
    Usage
    fi
    $FSLDIR/bin/imcp $TARGET FA/target
    cd FA
    do_reg target
fi

chmod 775 .commands
./.commands
