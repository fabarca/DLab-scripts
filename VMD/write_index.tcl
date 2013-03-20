# 
# write_index.tcl
#
# Fernando Abarca, December 2012
#
# Tcl script to write a gromacs index file selecting atoms using VMD
#
# Usage:
#        source write_index.tcl
#        set sel_lip [atomselect  top "same resid as name PO4 and x < 90 and y < 90"]
#        write_ndx $sel_lip System index2.ndx
#
# dlab.cl
#

proc write_ndx { sel_ndx name_group fname} {

set file_ndx [open "$fname" w]
       puts "\nWriting selection in $fname ..." 
       puts $file_ndx "\[$name_group\]"
       foreach serial [$sel_ndx get serial] {
               puts $file_ndx "$serial"
       }
       close $file_ndx
       puts "Done!\n\n"
}
