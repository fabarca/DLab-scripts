#The script divides the system in bins along the Z axis.
#In the script, I divided the system in 0.5 A bins.
#Also, I tell the script to do it for a total height of 150 A, starting from -50 A up to 100 A.
#So, in the script it's like this:
#	nslices = 300
#	slWidth = 150 / $nslices	# here i tell the script that my bins are 0.5 A wide, since i divide 150/300 = 0.5
#	slWidth = 1.0 / $slWidth	# i read somewhere that computing the inverse saved some cpu time, I don't really know why...

#I calculate the order parameter along each alkane molecule.
#For each segment of the molecule, I check in which bin along the Z axis it is located and accumulate it in that bin.
#
#Also, since in VMD i don't know how to load one frame at a time for calculate the parameter, i use an external script called "Bigdcd".
#Bigdcd allows you to load a trajectory one frame at a time, discarding each frame after ir has been used.
#In that way, you don't accumulate all frames in RAM memory and one would usually do it in VMD.
#For example:


source bigdcd.tcl
proc order {frame} {
    
global acum count id nslices slWidth p2 icntO icntH DOT idDOT name1 num_steps
# I open the file stream in writing mode	
	set fid1 [open $name1 a+]
# set the current frame and update the selection
	$DOT frame $frame
	$DOT update
# get the updated coordinates of the carbon atoms
	set coord [$DOT get {x y z}]
# set an empty list
	set coord_list [list]
# fill the list with 32-atom lists, since each alkane molecule has 32 atoms.
# the idea is that the list contains each molecule, one after the other.
	for {set j 0} {$j < [llength $coord]} {incr j 32} {
		set temp_c [lrange $coord $j [expr $j +31]]
		lappend coord_list $temp_c
	}
# set the lower limit of the system
	set zorg -50
# begin the loop to calculate the parameter over all molecules for the current frame.
# when all the trajectory has been analysed, this is skipped and the loop exits.
	if {$frame < [expr $num_steps]} {
		if {[llength $coord_list] !=0} {
# j is the number of the current alkane molecule.
			for {set j 0} {$j < [llength $coord_list]} {incr j} { 
# k is the index of the atom from which the vector is defined to begin
				for {set k 0} {$k < 29} {incr k} {
# l is the index of the atom located at k+3, the atom from which the vector is defined to end
					set l [expr $k + 3]
# Ci and Cf are the coordinates of the atoms corresponding to k and l indexes
					set Ci [lindex [lindex $coord_list $j] $k]
					set Cf [lindex [lindex $coord_list $j] $l]

# define the vectors for the cosine
					set mu [vecsub $Ci $Cf]
					set mun [veclength $mu]
		
# here it is defined the current slice in which the vector is located
					set zO    [expr ([lindex $Ci 2] - $zorg)]
					set sli   [expr floor([expr $slWidth * $zO] + 1)]
					set sli   [expr int($sli)]
# i don't know what this is for...
					set zH1   [expr ([lindex $Cf 2] - $zorg)]
					set sliH1 [expr floor([expr $slWidth * $zH1] + 1)]
					set sliH1 [expr int($sliH1)]

# here you do the P2 calculation

# first, you calculate the cosine of the angle
		 			set mudotn    [expr [lindex $mu 2] / $mun]
# cos^2
					set mudotn2   [expr $mudotn * $mudotn]
# (3*cos^2)-1
					set mudotn1   [expr (3 * $mudotn2) - 1]
# accumulate the value for the next vector located in the same bin
		 			set p2($sli)  [expr $p2($sli) + $mudotn1]
		
# i don't know what this does, but icntO($sli) is some kind of counter, necessary to compute the final average of P2 at each bin for every frame
					set icntO($sli)   [expr $icntO($sli)   + 1]
					set icntH($sliH1) [expr $icntH($sliH1) + 1]
				}
			}
		}
	}
#
# compute time averages of order parameters
#

# go through each slice and calculate the parameter
	for {set id 0} {$id  < $nslices} {incr id} {
# ztemp defines each bin in an arbitrary fashion.
# the first bin corresponds to -50 A in the Z axis and the last bin corresponds to 100 A.
		set ztemp [expr double($id)]
		set ztemp [expr $ztemp / $slWidth]
# if the current bin has something in it
		if {$icntO($id) != 0} {
# then, accumulate the value and recalulate the average at that frame. you might want to write this line in a paper to check what it is doing.
# the idea is to multiply the average times the number of frames, and then add the current parameter value, then calculate the average again. 
			set acum($id) [expr ($acum($id) * $count + (0.5 * $p2($id) / $icntO($id))) / ($count + 1)]
		}
# output the current bin and the parameter at that bin for the current bin
		puts $fid1 "$ztemp $acum($id)"
# reset these 2 variables to accumulate them in the next frame
		set p2($id)    0
		set icntO($id) 0
	}              
# move the global count one step forward
	set count [expr $count + 1]
	close $fid1
# this is just something to know in which frame the calculation is right now
	puts "$frame Done!"
}


# load the structure file (PSF) and the coordinates (PDB)
mol load psf ../DOT_SiO.psf pdb ../DOT_SiO.pdb
# define the amount of bins for the calculation
set nslices  300
# initialize the global counter
set count 0
# set the width of the bin. In this case, the width is 0.5 A, since 150/300 = 0.5
set slWidth [expr double(150) / double($nslices)]
set slWidth [expr 1.0 / $slWidth]
# initialize the atom selection
set DOT [atomselect top "resname DOT and not hydrogen"]
# i think these two variables are not used, but i kept them anyway
set idDOT [$DOT list]
set coord [$DOT get {x y z}]
# set the number of frames in the trajectory to analyze
set num_steps 2000

# initialize the variables to be used in the loop
for {set id 0} {$id  < $nslices} {incr id} {
	set p2($id)       0
	set acum($id)     0
	set icntO($id)    0
	set icntH($id)    0
}

# call bigdcd script, the order proc and the trajectory to be analyzed
bigdcd order ./300K_18-20ns.dcd
# set the output file name
set name1 "p2_DOT_18-20ns.dat"
set fid2 [open $name1 w]
close $fid2
