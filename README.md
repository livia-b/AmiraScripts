# AmiraScripts
Utility functions for Amira

To load the script go to the Amira console and type:

    source C:/<path>/mhdIO.tcl

Then for load and save mhd files,type in the console :
    readmhdfile  E:/file1.mhd
    writemhd imagenamw E:/file2.mhd
    
For automatically associate the metaimage file to this function, type
   dataFile -name "MetaImage" -ext "mhd" -package hxcore -load  hxReadByTcl -loadArgs "-cmd readmhdfile"
   
For load these settings at every startup, modify the amira.init file in amira installation folder

Know issues:
 * Not all fields are parsed (yet)
 * Works only with 16 bit images
 * Does not issue a warning if the image is in a not recognized format (e.g compressed, different from MET_SHORT, 2D...)
 
