# AmiraScripts
Utility functions for Amira

To load the script go to the Amira console and type:

    source C:/path/to/file/mhdIO.tcl

Then for load and save mhd files,type in the console :

     readmhdfile  E:/file1.mhd
     writemhdfile imagename E:/file2.mhd
    
For automatically associate the metaimage file to this function, type

     dataFile -name "MetaImage" -ext "mhd" -package hxcore -load  hxReadByTcl -loadArgs "-cmd readmhdfile"
   
For load these settings at every startup, modify the amira.init file in amira installation folder, or create a startup file .Amira in the home folder (like the one provided). Display console for seeing debug messages (Ctrl + Alt +A). For further info, see ch 9.2.3 (User-defined start-up script) and  9.3.5 (Amira Script Files) in  Amira user guide.

Know issues:
 * Not all fields are parsed (yet)
 * Works only with 16 bit images
 * Does not issue a warning if the image is in a not recognized format (e.g compressed, 2D...)
 * Does not check image orientation
 * Automatic loading fails when filepath contains a space *but typing in the console the filename between quotes works*
     readmhdfile  "path to/file.mhd" 
 
