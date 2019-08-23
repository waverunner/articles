# Ansible as documentation for Children's Laptops

A few of months ago I read the Opensource.com article [How to use Ansible to document procedures](https://opensource.com/article/19/4/ansible-procedures) by Marco Brvo. I will admit, I didn't quite get it at the time. I was not activelly using Ansible and I remember thinking it looked like more work than what it was worth. But I had an open mind and decided to spend time looking deeper into Ansbile.

I soon found an excuse to embark on my first real Ansible adventure, repurposing old laptops ala [How to make an old computer useful again](https://opensource.com/article/19/7/how-make-old-computer-useful-again). I always liked playing with old computers and the prospect of automating something with modern methods piqued my interest.

## The task at hand

Sometime earlier this year, I gave my 7 year old daughter a repurposed Dell mini 9 running some flavor of Ubuntu.  My 6 year old daughter initally didn't care much about this. As the music played and programs were discovered, interest set in.  Pretty soon I would have to build another.  Having a few old laptops and small children in the mix, I suspected I would be rebuiliding these things a few times. Failures, accidents, upgrades, corruptions ... a potential time sink over time.

And .... any parent out there with small children close in age (or twins) can likely identify with my dilema. If both children don't get identical things, conflicts will arise. Similar toys, similar clothes, similar shoes .. sometimes the color, shape, lights must be identical. I am sure any difference in a laptop configuration would be noticed and eventually a point of contention. I needed these laptops have identical functionality.

If you think about it, the task at hand seems ideal for a configuration managment system. I need something simple and some way to document what I'm doing so it can be and repeatable.

## Ansible to the rescue

I didn't try to set up a full-on PXE boot system to support an occasional laptop install. I wanted to teach my children to do some of the installtion work for me (a different kind of automation, ha!). I decided to start from a minimal OS install and eventually broke down my Ansible approach into 3 parts: bootstrap, account setup, and software installation. I could have put everything into 1 giant script, separting these files allowed me to mix and match them for other projects, and refine them idiindividually over time. Ansible's yaml file clarity helped to keep things clear as I refined my systems. For this laptop experiment I decided on using Debian 32-bit as my starting point as it seemed to work best on my older hardware.

Bootstrap script was intended to take a bare minimal OS install and bring it up to some standard. It relies on some non-root account being availble over SSH, and little else. It ensures Python is available, upgrades the OS, sets up an ansible account, and then transferrs SSH keys and configures sudo privelage escalation.

The account setup script is used to set up (or reset) user accounts for each family member. This keeps UID's consistant across small number of machines we have, and can be used to fix locked accounts when needed.

The software installation file is still evolving, but includes a base set of utilities for the sysadmin, and then the stuff my users will rely on.  This mostly consists of ensuring the same GUI interface is installed along with all the same programs, games, and music files.

I put the effort into creating these for the new M620 I was building until it worked as I needed it.  Once done, converting the mini 9 was a snap; I simply loaded the same minimal Debian install, ran the bootstrap, accounts, and software configurations, and the system functioned identically to the new system.

For a while, both sisters enjoyed their respective computers, comparing usage, and exploring fetures.

## The moment of truth
A few weeks later came the inevidable. My older daughter finally came to the conclusion that her pink mini 9 was underpowered. Her sister's D620 had superior power and screen real estate. Youtube became the rage, and the mini 9 could not keep up. As you can guess, the poor mini 9 fell into disuse and she desired a new machine; sharing her sister's would not do.

I had anohter D620 in my stock. I replaced the BIOS battery, gave it a new SSD, upgraded RAM, and was ready to go. Another perfect example of breathing new life into old hardware.

I pulled my ansible scripts from source control, and everything I needed was right there. Bootstrap, account setup, and software install. By this time I had fogrotten much of the specific software installation information. Things like UID's and all the packages installed. Surely I could have figured it out by spening time looking at my other machines, but no need! Ansible had it all clearly laid out in Yaml.

Not only was the documentation valuable, but Ansible's automation made short work of the new install. I attempted to time some of my activities. The minimal OS install from USB stick too about XX minutes. The subsequent shape up of the system for end-user deployment only took another YY minutes. 

## Conclusion

Taking the time to learn and practice Ansible through this exercise showed me the true value of its automation and documentation abilities.  A few hours figuring out the specifics for the first example saves me time whenever I need to provision or fix a machine. The Yaml is clear, easy to read, and thanks to Ansible's idempotency, easy to refine over time.