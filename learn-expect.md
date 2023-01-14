# Learn the Expect programming utility by writing (and automating!) a simple game

Learn how to use the Expect command line automation utility based on TCL by writing a simple "guess the number" game. Then automate the game to make your guesswork more efficient.
  
Hopefully you were able to enjoy my previous article [Learn the TCL programming language by writing a simple game](). Here is a brief recap: I was set on creating an Ansible automation to deploy and configure software for my work environment. I hit one configuration utility that just defied any real automation. It was a java process that didn't support a silent installer, it wouldn't handle stdin very gracefully, had an inconsistant set of prompts, lots of output to weed through, and printed bits along that way that were important to retain. Ansible's expect module was woefully inadequte for this task; poor documentation, cumbersome yaml syntax, and lack of control flow flexibility. I hadn't used Expect in many years -- now was the time to brush up on those skills to actually get something done.

My journey to Expect meant learning a bit of TCL, and so the result was my previous article referenced above.  Now that I had the background to create simple programs, I could get to the meat of learning Expect. I thought it fun to create another article here to demonstrate some of the cool functionality of this venerable utlity.

This article will go beyond the typical 'simple game' format. We'll be using the parts of Expect to create the game itself, and then I'll demonstrate the real power of Expect with a separate script to automate playing this game.

This programming exercise shows several classig programming examples of variables, input, output, conditional evaluation, and loops.


## Installing Expect
I use MacOS on a daily basis. I found that my version of Expect was included in the base operating system:
```
$ which expect
/usr/bin/expect
```

For Mac you can also load a slightly newer version using brew:
```
$ brew install expect
$ which expect
/usr/local/bin/expect
```

But for our purposes the MacOs system default is just fine.

For my Linux RedHat 8 based systems I would do:
```
# dnf install expect
# which expect
/bin/expect
```

# Guess the number in Expect
The number guessing game using expect is not that much different than the base TCL I used in my previous article. 

For a brief recap from TCL: All things in TCL are strings including variable values. Code lines are best contained by curly braces (Instead of trying to use line continuation), and square brackets aer used for command substitution. Command substitution is very handy for deriving values from other functions to be used directly as input where needed. Well see all of this in the subsequent script.

Create a new game file `numgame.exp`, set it to be executible, and then enter the script below:

```
#!/usr/bin/expect

proc used_time {start} {
	return [expr [clock seconds] - $start]
}

set num [expr round(rand()*100)]
set starttime [clock seconds]
set guess -1
set count 0

send "Guess a number between 1 and 100\n"

while { $guess != $num } {
	incr count
	send "==> "

	expect {
		-re "^(\[0-9]+)\n" {
			send "Read in: $expect_out(1,string)\n"
			set guess $expect_out(1,string)
		}

		-re "^(.*)\n" {
			send "Invalid entry: $expect_out(1,string) "
		}
	}

	if { $guess < $num } {
		send "Too small, try again\n"
	} elseif { $guess > $num } {
		send "Too large, try again\n"
	} else {
		send "That's right!\n"
	}
}

set used [used_time $starttime]

send "You guessed value $num after $count tries and $used elapsed seconds\n"
```

`proc` sets up a function (or procedure) defination. This consists of the name of the function, followed by a list containing the parameters (1 parameter `{start}`) and then followed by the function body. The return statment shows a good example of nested TCL command substitution. The `set` statements define variables and the first 2 of these use command substitution to store a random number and the current system time in seconds respectivelly.

The `while` loop and if-elsif-else logic should be familiar. Note again the particular placement of the curly braces to help group multiple command strings together without needing line continuation.

The big difference you will see here (from previous TCL program) is use of the functions `expect` and `send` rather than using `puts` and `gets`. `expect` and `send` form the core of Expect program automation.  In this case we are using these functions to automate a human at a terminal; later we will automate a real program.  `send` in this context isn't much more than printing information to screen. The `expect` command is a bit more complex.

The `expect` command can take a few different forms depending on the complexity of your processig needs. The typical use consist of one of more pattern-action pairs such as:
```
expect "pattern1" {action1} "pattern2" {action2}
```
More complex needs can place multiple pattern action pairs within curly braces optionally prefixed with options that alter the processing logic.  The form I used above encapulates multiple pattern-action pairs. It uses the option `-re` to apply regex processing (vs glob processing) to the pattern, and follows this with curly braces that can encapsulate one or more statements to execute. I've defined 2 patterns above. The first:
```
"^(\[0-9]+)\n"
```
Is intended to match a string of 1 or more numbers. The 2nd pattern:
```
"^(.*)\n" 
```
is designed to match anything else that is not a string of numbers.

Take note that this use of `expect` is executed repeatedly from within a `while` statement; a perfectly valid approach to reading multiple entries.  In the automation I will show a slightly variation of expect that does the iteration for you.

Finally, the `$expect_out` variable is an array used by `expect` to hold the results of it's processing. In this case the variable `$expect_out(1,string)` holds the first captured pattern of the regex.

# Run the game
There should be no surprises here:
```
$ ./numgame.exp 
Guess a number between 1 and 100
==> Too small, try again
==> 100
Read in: 100
Too large, try again
==> 50
Read in: 50
Too small, try again
==> 75
Read in: 75
Too small, try again
==> 85
Read in: 85
Too large, try again
==> 80
Read in: 80
Too small, try again
==> 82
Read in: 82
That's right!
You guessed value 82 after 8 tries and 43 elapsed seconds
```
One difference you may notice is the impatience this version exhibits.  If you dilly-dally long enough, expect times out with an invalid entry and prompts you again. This is differnt from `gets` which waits indefinitely. The `expect` timeout is a configurable feature to help deal with hung programs or die on unexpected output.

# Automate the game in Expect
For this example the expect automation script will need to be in the same folder as your `numgame.exp` script. Create the `automate.exp` file, make it executable, open your editor and enter the following:
```
#!/usr/bin/expect

spawn ./numgame.exp

set guess [expr round(rand()*100)]
set min 0
set max 100

puts "I'm starting to guess using the number $guess"

expect {
     -re "==> " { 
        send "$guess\n"
        expect {
             "Too small" {
                 set min $guess
                 set guess [expr ($max+$min)/2]
             }
             "Too large" {
                 set max $guess
                 set guess [expr ($max+$min)/2]
             }
             -re "value (\[0-9]+) after (\[0-9]+) tries and (\[0-9]+)" {
                 set tries  $expect_out(2,string)
                 set secs   $expect_out(3,string)
            }
        }
        exp_continue
    }

    "elapsed seconds" 
}

puts "I finished your game in about $secs seconds using $tries tries"
```

The `spawn` function executes the program we want to automate; it takes as separate strings the command followed by the arguments to pass to it. I then `set` the initial number to guess and the real fun begins from there.

This `expect` statement is considerably more complicated and illustrates the power of this utility. Note that there is no looping statement here to iterate over the prompts.  Because my game has predictable prompts I can ask `expect` to do a little more processing for me.  The outer `expect` attempts to match the game input prompt of `==> `. Seeing that, it will `send` a guess and then use an additional `expect` to figure out the results of such guess. Depending on the output, variables are adjusted and calulated to set up the next guess.  When the prompt `==> ` is matched the `exp_continue` statement is invoked which causes the outer `expect` to be re-evaluated. So then a loop here is no longer needed.

This input processing relies on another behavior of expect's processing.  Expect will buffer the terminal output until it matches a pattern. This buffering includes any embedded end of line and other unprintable characters -- this is different than the typical regex line matching we are used to with awk and perl.  When a pattern is matched, anything coming after the match ramains in the buffer and is made available for the next match attempt. I've exploited this to cleanly end the outer `expect` statement.  You will see that the inner pattern:
```
-re "value (\[0-9]+) after (\[0-9]+) tries and (\[0-9]+)"
```
matches the correct guess and does not consume all of the characters printed by the game. The very last part of the string ("elapsed seconds") is still buffered after the successful guess. On the next evaluation of the outer `expect`, this string is matched from the buffer to cleanly end (no action is supplied).

# Run the automated game

Now for the fun part, let's run the full automation:

```
$ ./automate.exp 
spawn ./numgame.exp
I'm starting to guess with the number 99
Guess a number between 1 and 100
==> 99
Read in: 99
Too large, try again
==> 49
Read in: 49
Too small, try again
==> 74
Read in: 74
Too large, try again
==> 61
Read in: 61
Too small, try again
==> 67
Read in: 67
That's right!
You guessed value 67 after 5 tries and 0 elapsed seconds
I finished your game in about 0 seconds using 5 tries
```
Wow! My number guessing efficiency dramatically increased thanks to automation! A few trial runs I resulted in anywhere from 5-8 guesses on average, and always completed in under 1 second. Now that this pesky, time consuming fun can be dispatched so quickly, I have no excuse to dely other more important tasks like working on my linguring home-improvement projects :P

# Never stop learning
This article was a bit lengthy, but well worth the effort. The number guessing game was trivial but offered a good base for demonstrating a more interesting example of Expect processing. I learned quite a bit from the exercise, and was able to complete my work automation successfully.  I hope you found this programming example interesting, and it helps you to further your automation goals.