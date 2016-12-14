#!/usr/bin/tclsh

proc cbloc {args} {
    set final_code {}
    set semicolon 0
    foreach token $args {
        puts -nonewline $::C " "
        if {[llength [split $token \n]]<=1} {
	    puts -nonewline $::C [uplevel [list subst -nobackslashes $token]]
	    set semicolon 1
	    continue
	}
	puts $::C "\{"
	uplevel $token
	puts -nonewline $::C "\}"
	set semicolon 0
    }
    if {$semicolon} {
        puts $::C ";"
    } else {
        puts $::C ""
    }
}
proc ppbloc {args} {
    set final_code {}
    foreach token $args {
        puts -nonewline $::C " "
        if {[llength [split $token \n]]<=1} {
	    puts -nonewline $::C [uplevel [list subst -nobackslashes $token]]
	    continue
	}
	puts $::C "\{"
	uplevel $token
	puts -nonewline $::C "\}"
	set semicolon 0
    }
    puts $::C ""
}
proc comment {comment} {
    set comment [uplevel [list subst -nobackslashes $comment]] 
    puts $::C "// $comment"
}
proc preprocess {code} {
    set final_code {}
    set block {}
    set rank 0
    foreach line [split $code \n] {
	append final_code \n
        if {[regexp {^\s*\.(.*)$} $line -> line_code]} {
	    append final_code $line_code
	    continue
	}    
        if {[regexp {^\s*$} $line -> line_code]} {
	    continue
	}    
	if {[regexp {^\s*\#} $line]} {
	    append final_code "ppbloc \{$line\}"
	    continue
	}
	if {[regexp {^\s*\}} $line]} {
	    append final_code $line
	    continue
	}
	if {[regexp {^\s*\/\/(.*)} $line -> comment]} {
	    append final_code [list comment $comment]
	    continue
	}
	if {[regexp {^(.*)\{\s*$} $line -> preemble]} {
	    append final_code "cbloc \{$preemble\} \{" 
	    continue
	}
	append final_code  "cbloc \{$line\}" 
    }
    uplevel $final_code
}


proc compile_all {dir target} {
    puts "DIR=$dir"
    foreach file [glob -nocomplain $dir/*] {
        set target_file [file join $target [file tail $file]]
        if {[file isdirectory $file]} {
	    if {![file exists $target_file]} {
	        file mkdir $target_file
	    }	
	    compile_all $file $target_file
	    continue
	}
	if {[file exists $target_file]} {
	   # if {[file mtime $target_file]>=[file mtime $file]} continue
	}
	puts "Preprocessing $file"
	set I [open $file r]
	set ::C [open $target_file w]
	preprocess [read $I]
	close $::C
	close $I
	    
    }
}
proc unknown {args} {
    if {[regexp {^\.(.*)$} $args -> code]} {
        return [uplevel $code]
    }
    return "\[$args\]"
}

compile_all [file join [pwd] source] [file join [pwd] preprocessed]


exit
