proc calc_dist_mol {axis molid sel_name1 sel_name2 {output printlist}} {
        set num_steps [molinfo $molid get numframes]
	set sel1 [atomselect $molid "$sel_name1"]
	set sel2 [atomselect $molid "$sel_name2"]
	set axisnum(x) 0
	set axisnum(y) 1
	set axisnum(z) 2

        for {set frame 0} {$frame < $num_steps} {incr frame} {
		# Update
		animate goto $frame
		measure center $sel1
		# Write number of water molecules
		set dist [expr [lindex [measure center $sel1] $axisnum($axis)] - [lindex [measure center $sel2] $axisnum($axis)]]
		lappend list_dist $dist
		if {$output == "printlist"} {
    			puts "$dist"
		} 
        }

	if {$output == "returnlist"} {
		return $list_dist
	} 

}

proc write_dist_mol {axis molid sel_name1 sel_name2} {
	# Create directory
	set dir "data"
	file mkdir ${dir}

	# Create file
	set dist_dat [open ${dir}/dist_${axis}_${sel_name1}-${sel_name2}.dat w]

	# Loop variables	
	puts "Calculating distance in $axis between the centers of $sel_name1 and $sel_name2..."
	
	set dist_list [calc_dist_mol $axis $molid $sel_name1 $sel_name2 returnlist]
	set num_steps [llength $dist_list]

        for {set frame 0} {$frame < [expr $num_steps -1]} {incr frame} {
		# Save dist per frame
		set x [lindex $dist_list $frame]
		puts $dist_dat "$x"

	}

	puts "Done!"
	close $dist_dat
}


#Examples
puts "Examples:\n"
puts "calc_dist_mol z top protein lipids      # Add \"returnlist\" to return a list instead of print the output"
puts "write_dist_mol z top protein lipids     # Save distance in z axis between the centers of protein and lipids"
