proc calc_wt_shell { cutoff molid sel_name} {
        set num_steps [molinfo $molid get numframes]
	set wt_s [atomselect $molid "name OW and within $cutoff of $sel_name"]
	#puts "Calculating water shell within $cutoff angstroms of $sel_name..."

        for {set frame 0} {$frame < $num_steps} {incr frame} {
		# Update
		animate goto $frame
		$wt_s update

		# Write number of water molecules

		lappend wt_shell [$wt_s num]
        }
	return $wt_shell
}

proc write_wt_shell_per_resid {cutoff molid sel_name} {
	# Create directory
	set dir "data"
	file mkdir ${dir}

	# Create file
	set wt_shell_dat [open ${dir}/wt_shell_${sel_name}_${cutoff}.dat w]

	# Loop variables	
        set num_steps [molinfo $molid get numframes]	

	set num_resids [[atomselect $molid "name CA and $sel_name"] get resid]

	set resnames [[atomselect $molid "name CA and $sel_name"] get resname]
	
	puts "Calculating water shell within $cutoff angstroms of $sel_name..."
	
	foreach i $num_resids {
		# Calculate water shell for each resid
		set datalist($i) [calc_wt_shell $cutoff $molid "resid $i"]

		# Write column names to output file header
		puts -nonewline $wt_shell_dat "[lindex $resnames $i-1]-$i\t"
	}
	

	puts $wt_shell_dat ""

	puts "Saving data..."

        for {set frame 0} {$frame < $num_steps} {incr frame} {
		foreach i $num_resids {
			# Save water shell per frame
			set x [lindex $datalist($i) $frame]
			puts -nonewline $wt_shell_dat "$x\t"
	
		}
		puts $wt_shell_dat ""
        }
	puts "Done!"
	close $wt_shell_dat
}

#Examples
puts "Examples:\n"
puts "calc_wt_shell 5 top resid 1             # Show water shell at 5 A for resid 1\n"
puts "write_wt_shell_per_resid 5 top protein  # Save water shell at 5 A foreach resid in \"protein\"\n"
