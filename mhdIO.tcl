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
    while {$thisSize >= 0} {
      # update header size
        set headerSize [expr $headerSize + $thisSize]
		# $line
        if { [scan $line "ElementDataFile = %s" ElementDataFile ] == 1 } {
            break;
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
	
	
        set thisSize [gets $fp line]
    }
	set DataFile ${folder}${ElementDataFile}
    # assuming 16 bit here (*2)
    set headerSize [expr [file size ${DataFile}] - ($x*$y*$z*2)]
    echo "filesize $DataFile is $x $y $z (header $headerSize)"
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
    echo " load -raw ${DataFile} little xfastest short 1 $x $y $z $origx $xmax $origy $ymax $origz $zmax -header $headerSize"

    [ load -raw $DataFile little xfastest short 1 $x $y $z $origx $xmax $origy $ymax $origz $zmax -header $headerSize] setLabel $filename
    return 1
}


proc writemhdfile {image mhdfile} {

	scan [$image getBoundingBox] "%f %f %f %f %f %f" xmin xmax ymin ymax zmin zmax
	scan [$image getDims] "%d %d %d" x y z
	scan [$image getVoxelSize] "%f %f %f" xsp ysp zsp
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
	puts $fo "Debug Info"
	puts $fo [format "Saved on %s ; cmd: writemhd $image $mhdfile"  [clock format $systemTime -format "%D %H:%M:%S"] ]
	puts $fo "ElementType = MET_SHORT"
	set filename [lindex [split $rawfile "/"] end]
    puts $fo [format "ElementDataFile = %s" $filename]
	close $fo
	$image exportData "Raw Data 3D" $rawfile
}


#uncomment this command to automatically associate the mhd file to readmhdifle 
#dataFile -name "MetaImage" -ext "mhd" -package hxcore -load  hxReadByTcl -loadArgs "-cmd readmhdfile"

