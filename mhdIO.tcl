# Amira-Script-Object V3.0

# this is a reader for the file format .mhd
# adapted from http://mc3dviz.com/avizo-forum/showthread.php?t=23
# $this script show

# $this proc constructor {} {
   # $this newPortInfo text
   # $this text setValue "Please select a .mhd file from disc"
   # $this newPortFilename fileselection
   # $this fileselection setLabel "Input File"
   # $this fileselection setMode 0

   # $this newPortButtonList doit 1
   # $this doit setLabel ""
   # $this doit setLabel 0 "Load"
 # }

#$this 


proc readmhdfile {mhdfile} {
    # if { ![$this doit wasHit 0] } {
	# return
    # }
    
    # set mhdfile [$this fileselection getFilename]
    if { $mhdfile == "" } {
	return 0
    }
    
    set x 1
    set y 1
    set z 1 
    set headerSize 0
    set origx 0
    set origy 0
    set origz 0
	
	set lastSlash [string last "/" $mhdfile]
	set folder [string range $mhdfile 0 $lastSlash]
	set filename [string range $mhdfile [expr $lastSlash+1] end]
    
    set fp [open $mhdfile "r"]
    echo now scan in the mhdfile and read out the parameters
    # ...
    set thisSize [gets $fp line]
			   set notstdTransform 0

    while {$thisSize >= 0} {
      # update header size
        set headerSize [expr $headerSize + $thisSize]
		#echo $line
        if { [scan $line "ElementDataFile = %s" ElementDataFile ] == 1 } {
            break;
	}  
	    if { [scan $line "ObjectType = %s" ObjectType ] == 1 } {
            if {$ObjectType != "Image"} {
			return 0
			}
	}
	
	     if { [scan $line "CompressedData = %s" CompressedData ] == 1 } {
            if {$CompressedData != "False"} {
			return 0
			}
	}
	
		if { [scan $line "BinaryDataByteOrderMSB = %s" BinaryDataByteOrderMSB ] == 1 } {
            if {$BinaryDataByteOrderMSB == "False"} {
				set endianness "little"
			} else {
				set endianness "big"
	}
	}
	#echo [scan $line "ElementType = %s" ElementType ]
	if { [scan $line "ElementType = %s" ElementType ] == 1 } {
	        #echo ElementType $ElementType
            if {$ElementType == "MET_SHORT"} {
				set pixelType "short"
				set pixelBytes 2
			} elseif {$ElementType == "MET_UCHAR"} {
			    set pixelType "byte"
				set pixelBytes 1
			} else {
			echo "$ElementType not implemented"
			return 0
			}
			}
			
			
        #look for size
        if { [scan $line "DimSize = %d %d %d" xtmp ytmp ztmp] == 3 } {
            set x $xtmp
            set y $ytmp
            set z $ztmp
	}
        # look for origin
        if { [scan $line "Offset = %f %f %f" xtmp ytmp ztmp] == 3 } {
            set origx $xtmp
            set origy $ytmp
            set origz $ztmp
	}
	
	   # look for spacing
        if { [scan $line "ElementSpacing = %f %f %f" xtmp ytmp ztmp] == 3 } {
            set spx $xtmp
            set spy $ytmp
            set spz $ztmp
	}
	
		   # look for spacing
   if { [scan $line "TransformMatrix = %f %f %f %f %f %f %f %f %f" xx xy xz yx yy yz zx zy zz] == 9 } {
         echo $line
            if {$line !=  "TransformMatrix = 1 0 0 0 1 0 0 0 1"} {
				echo "Not Standard Transform"
				set notstdTransform 1
			}
			
	}
	

        set thisSize [gets $fp line]
    }
	set DataFile ${folder}${ElementDataFile}
    #echo ElementType $ElementType
	set DataFileSize [file size ${DataFile}] 
    set headerSize [expr $DataFileSize - ($x*$y*$z*$pixelBytes)]
    echo "filesize $DataFile   is $x $y $z (header $headerSize) (total size $DataFileSize "
    close $fp
	if { $headerSize != 0} {
	echo "Error in computing header size  $DataFile "
	return 0
    }
    #set filename [lindex [split $mhdfile "/"] end]
    #echo "amira variable is $filename"
	#echo "spacing is $spx"

	
	set xmax [expr ($x-1)*$spx+$origx] 
	set ymax [expr ($y-1)*$spy+$origy]
	set zmax [expr ($z-1)*$spz+$origz]

    # now load the data file as raw data with the parameters
    echo " load -raw ${DataFile} $endianness xfastest $pixelType 1 $x $y $z $origx $xmax $origy $ymax $origz $zmax -header $headerSize"

    set loaded_data [ load -raw $DataFile $endianness xfastest $pixelType 1 $x $y $z $origx $xmax $origy $ymax $origz $zmax -header $headerSize] 
	#setLabel $filename    
	echo "Transdorm" $notstdTransform
	if {$notstdTransform == 1} {
		echo 	"$loaded_data setTransform $xx $xy $xz 0 $yx $yy $yz 0 $zx $zy $zz 0 0 0 0 1"
		$loaded_data setTransform $xx $xy $xz 0 $yx $yy $yz 0 $zx $zy $zz 0 0 0 0 1
		
	}
	
    return 1
}

proc checkIfNiiFile {image} {
	if {[$image getVoxelSize] != "1 1 1"} {
		return 0
	}
	if { [scan [$image getTransform]  "%f 0 0 0 0 %f 0 0 0 0 %f 0 %f %f %f 1" xx yy zz tx ty tz] != 6 } {
		return 0
	}
	if { [scan [$image getBoundingBox] "0 %d 0 %d 0 %d" xmax ymax zmax ] != 3 } {
		return 0
	}
	return 1
}



proc writemhdfile {image mhdfile} {

	scan [$image getBoundingBox] "%f %f %f %f %f %f" xmin xmax ymin ymax zmin zmax
	scan [$image getDims] "%d %d %d" x y z
	scan [$image getVoxelSize] "%f %f %f" xsp ysp zsp
	#scan [$image getTransform] "%f %f %f %f %f %f %f %f 1" xx xy xz xt yx yy yz yt zx zy zz zt tx ty tz  
	if { [$image getTransform] != "1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1" } {
		if {[checkIfNiiFile $image ]== 1} {
			scan [$image getTransform]  "%f 0 0 0 0 %f 0 0 0 0 %f 0 %f %f %f 1" xsp ysp zsp xmin ymin zmin
			#I don't update the values of xmax, ymax, zmax becuase I don't need them
			echo "WARNING: transform compatible with Nifti, applied during export"
			echo [format "ElementSpacing = %f %f %f" $xsp $ysp $zsp  ]	
			echo [format "Offset = %f %f %f" $xmin $ymin $zmin] 
			} else {
			echo "WARNING: a transform is applied to $image , it wil be ignored during export"
			}
			
	}
	
	if {[scan [$image Datainfo getValue Content] "grayscale, 8-bit unsigned, min-max: %s"   intensityrange] == 1 } {
		set pixelType "MET_UCHAR"
		#echo "pixelType uchar [$image Datainfo getValue Content]"
	} elseif {[scan [$image Datainfo getValue Content]  "grayscale, 16-bit signed, min-max: %s"   intensityrange] == 1} {
		set pixelType "MET_SHORT"
		#echo "pixelType short --[$image Datainfo getValue Content]--"
	} else {
	  echo "WARNING: writer does not implement this pixel type, fix manually in  $mhdfile ([$image Datainfo getValue Content])"
	    set pixelType "FIXME"
	}
	
	
	#echo "dimension x " $x  $xmax $xmin
	# set xsp [expr ($xmax-$xmin)/($x-1)]
	# set ysp [expr ($ymax-$ymin)/($y-1)]
	# set zsp [expr ($zmax-$zmin)/($z-1)]
	set fo [open $mhdfile "w"] 
	set rawfile "${mhdfile}.raw"
	puts $fo "ObjectType = Image"
	puts $fo "NDims = 3"
	puts $fo "BinaryData = True"
	puts $fo "BinaryDataByteOrderMSB = False"
	puts $fo "CompressedData = False"
	puts $fo "TransformMatrix = 1 0 0 0 1 0 0 0 1"
	puts $fo [format "Offset = %f %f %f" $xmin $ymin $zmin] 
	puts $fo "CenterOfRotation = 0 0 0"
	puts $fo "AnatomicalOrientation = RAI"
	puts $fo [format "ElementSpacing = %f %f %f" $xsp $ysp $zsp  ]	
	puts $fo [format "DimSize = %d %d %d" $x $y $z ]
	set systemTime [clock seconds]
	puts $fo [format "DebugInfo = Saved on %s ; cmd: writemhd $image $mhdfile"  [clock format $systemTime -format "%D %H:%M:%S"] ]
	puts $fo [format "AmiraTransform = %s " [$image getTransform]] 
	puts $fo "ElementType = $pixelType"
	set filename [lindex [split $rawfile "/"] end]
    puts $fo [format "ElementDataFile = %s" $filename]
	close $fo
	$image exportData "Raw Data 3D" $rawfile
}


#uncomment this command to automatically associate the mhd file to readmhdifle 
#dataFile -name "MetaImage" -ext "mhd" -package hxcore -load  hxReadByTcl -loadArgs "-cmd readmhdfile"

