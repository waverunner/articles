# Learn the TCL programming language by writing a simple game

Learn how to program in TCL by writing a simple "guess the number" game.

My path to TCL started with a recent need to automate a difficult java based CLI configuration utility. I do a bit of automation programming using Ansible and occasionally use the expect module. Frankly, I find this module of very limited utility for a number of reasons including: difficulty with sequencing identical prompts, capturing values for use in additional steps, limited flexibility with control logic, etc. Not to mention the Ansible expect docs are quite lacking in detail.  Trivial cases can often be fulfilled. Sometimes you can get away by using the shell module instead. But sometimes you hit that ill-behaving and overly complicated CLI that seems impossible to automate.  In my case, I was automating the installation of one of my company's programs and the last configuration step could only be done via CLI through a number of ill formed, repeating prompts, and data output that needed capturing. The good ol' traditional Expect was really the only answer.  You probably don't need a really deep understanding of TCL to use the basics of Expect, but the more the know the more power you can get from it. This will be a topic for a follow-on article. For now, we'll explore the basic language constructs of TCL which include user input, output, variables, conditional evaluation, looping, and simple functions.

## Installing TCL
I use MacOS on a daily basis. I found that several options exist here. Apple has a slightly older verion 8.5 that is found in `/usr/bin/tclsh`. On my machine a newer version 8.6 was already in my path as a side affect of installing the miniconda environment manager. See my previous article XXXXX for using this utility on MacOS. If you are not using miniconda, you can also use brew to install the a newer version of 8.6.x via the tcl-tk package:
```
$ brew install tcl-tk
$ which tclsh
/usr/local/bin/tclsh
```

For my Linux RedHat 8 based systems I would do:
```
# dnf install tcl
# which tclsh
/bin/tclsh
```
# Guess the number in TCL

Start by creating the basic executable script `numgame.tcl`: 

```
$ touch numgame.tcl
$ chmod 755 numgame.tcl
```

And then start coding in your file headed up by the usual shebang script header:


```
#!/usr/bin/tclsh

```

So lets have a few quick words about artificats of TCL to track along with this article.

Firstly, all of TCL is considered to be a series of strings.  This includes all variables which only store string values. Now, some functions may interpret these strings as numbers (ala `expr`) but ultimately all these things are stored and passed as strings. Strings are usually delineated using double quote or curly braces. Double quotes allow for variable expansion and escape sequences where as curly braces impose no expansion at all.

Second ,TCL statments don't use end of line termination like colon or semicolon. Statement lines can be split using the back slash (\) character, however it's typical to enclose multiple statements within curly braces to avoid needing such. Curly braces are just simpler and the code formatting below reflects this. Curly braces allow for deferred evaluation of strings which allows for passing values to functions before tcl does anything like variable substitution.

Thirdly, TCL uses square brackets for command substitution. Anything between the square brackets is sent to a new recursive invocation of the tcl interpertor for evaluation. This is handy for calling functions in the middle of expressions or for genrating parameters to functions.

## Procedures
Although not necessary for this trivial game, let's start with an example of defining a function in TCL that we can use later:
```
proc used_time {start} {
	return [expr [clock seconds] - $start]
}
```

`proc` sets this up to be a function (or procedure) defination. Next comes the name of the function. This is then followed by a list containing the parameters; in this case 1 parameter `{start}` and then followed by the function body. Note that the body curly brace starts on this line, it cannot be on the following line.  The function returns a value.  The returned value is a compund evaluation (square braces) that starts by reading the system clock `[clock seconds]` and does the math to subtract out the `$start` parameter.

## Setup, Logic, and finish

Flesh out the rest of this game with some initial setup, iterating over the player's guesses, and then printing some results when completed:

```
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
```

The first set of `set` statements set up variables to track.  The first 2 evaluate expressions to discern a random number between 1-100 and the the next saves the system clock start time.

`puts` and `gets` are used for output to and input from the player.  The `puts` I've used imply standard out for output. `gets` needs the input channel to be defined so we specify `stdin` does standard in from the user.

The `flush stdout` is needed when `puts` omits the end of line termination becuase TCL buffers output and it might not get displayed before the next I/O is needed.

From there the `while` statement illustrates the looping control structure and conditional logic needed to give the player feedback and eventually end the loop.

The final `set` command calls our function to calcualte elapsed seconds for game play, followed by the collected stats to end the game.

# Play it!

```
 ./numgame.tcl
Guess a number between 1 and 100
==> 100
Too large, try again
==> 50
Too large, try again
==> 25
Too large, try again
==> 12
Too large, try again
==> 6
Too large, try again
==> 3
That's right!
You guessed value 3 after 6 tries and 20 elapsed seconds
```

# Continue learning
When I started this exercise, I seriously doubted just how useful going back to a late 1990's fad language would really be worthwile to me. Along the way I found a few things about TCL that I really enjoyed -- so far my favorite being that square bracket command evaluation. It just seems so much easier to read and use than many other languages that over use complicated closure structures.  What ai thought was a dead language was actually still thriving and supported on several platforms. I learned a few new skills and grew appreciation for this venerable language.

Check out the official site over at: [https://www.tcl-lang.org](https://www.tcl-lang.org) and you will find references to the latest source, binary distributions, forums, docs, and information on conferences that are still ongoing.

