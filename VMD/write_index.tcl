# 
# write_index.tcl
#
# Fernando Abarca, December 2012
#
# Tcl script to write a gromacs index file using a selection of atoms
#
# dlab.cl
#

proc write_ndx { sel_ndx name_group fname} {

set file_ndx [open "$fname" w]
       puts "\n Writing selection in $fname ..." 
       puts $file_ndx "\[$name_group\]"
       foreach serial [$sel_ndx get serial] {
               puts $fndx "$serial"
       }
       close $file_ndx
       puts "Done!\n\n"
}
