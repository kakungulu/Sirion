#!/usr/bin/tclsh

proc cbloc {code} {
    return $code
}
proc preprocess {code} {
    set rank 0
    set buffer ""
    set retval {}
    foreach line [split $code \n] {
        append buffer "$line\n"
	if {[regexp {[^\\]\{\s*$} $line]} {
	    incr rank  
	} 
	if {[regexp {^\s*\}\s*$} $line]} {
	    incr rank -1
	}
	if {$rank!=0} continue
	set buffer_list $buffer
	set buffer {}
        foreach arg $buffer_list {
            if {[llength [split $arg \n]]==1} {
	        lappend buffer [subst $arg]
	        continue
	    }
	    lappend buffer [uplevel [list preprocess $arg]]
        }
	if {[regexp {^\s*\.} $buffer]} {
	    regsub {^\s*\.} $buffer {} buffer
	    append retval [uplevel $buffer]
	} else {
	    append retval [uplevel [list subst $buffer]]
	}
	set buffer ""
    }
}


proc compile_all {dir target} {
    foreach file [glob -nocomplain $dir/*] {
        set target_file [file join $target [file tail $file]
        if {[file isdirectory $file]} {
	    if {![file exists $target_file]} {
	        file mkdir $target_file
	    }	
	    compile_all $file $target_file
	    continue
	}
	if {[file exists $target_file]} {
	    if {[file mtime $target_file]>=[file mtime $file]} continue
	}
	    
    }
}



exit
