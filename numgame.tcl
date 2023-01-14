#!/usr/bin/tclsh

proc used_time {start} {
	return [expr [clock seconds] - $start]
}

set num [expr round(rand()*100)]
set starttime [clock seconds]
set guess -1
set count 0

puts "Guess a number between 1 and 100"

while { $guess != $num } {
	incr count
	puts -nonewline "==> "
	flush stdout
	gets stdin guess

	if { $guess < $num } {
		puts "Too small, try again"
	} elseif { $guess > $num } {
		puts "Too large, try again"
	} else {
		puts "That's right!"
	}
}

set used [used_time $starttime]

puts "You guessed value $num after $count tries and $used elapsed seconds"
