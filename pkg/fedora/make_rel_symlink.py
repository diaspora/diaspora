#!/usr/bin/env python

import os
import os.path
import sys
import pdb
import shutil

def relative_ln_s( from_, to_ ):
    """

    This is just so dirty & boring: create a relative symlink, making the
    to_ path relative to from_. No errorchecks. Both arguments must be
    files, a destination directory doesn't work (I think). An existing
    file in to_ will be removed.

    """
    prefix = os.path.commonprefix( [ to_, from_ ] )
    if prefix == '':
        prefix = '/'
    source = from_.split( prefix )[ 1 ]
    dest   = to_.split( prefix )[ 1 ]
    level = len( dest.split( '/' ) ) - 1
    path =  ( '../' * level ) + source
    return path

USAGE = 'Usage: make_rel_symlink [-p]  <sourcefile> <destfile>'

just_print = False;
if sys.argv[1] == "-p":
    just_print = True;
    sys.argv = sys.argv[ 1:]

if len( sys.argv ) != 3:
    print USAGE
    sys.exit( 1 )

if  os.path.isdir(  sys.argv[2] ):
    print "Removing link target dir:" +  sys.argv[2]
    shutil.rmtree( sys.argv[2])

link_path = relative_ln_s( sys.argv[1], sys.argv[2] )
if just_print:
    print link_path
else:
    os.chdir( os.path.dirname( sys.argv[2]))
    target = os.path.basename( sys.argv[2])
    if os.path.exists( target ):
        os.unlink( target)
    os.symlink( link_path, target)


