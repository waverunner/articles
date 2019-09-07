# Ansible as documentation for Children's Laptops

A few of months ago I read the Opensource.com article [How to use Ansible to document procedures](https://opensource.com/article/19/4/ansible-procedures) by Marco Brvo. I will admit, I didn't quite get it at the time. I was not activelly using Ansible and I remember thinking it looked like more work than what it was worth. But I had an open mind and decided to spend time looking deeper into Ansbile.

I soon found an excuse to embark on my first real Ansible adventure, repurposing old laptops ala [How to make an old computer useful again](https://opensource.com/article/19/7/how-make-old-computer-useful-again). I always liked playing with old computers and the prospect of automating something with modern methods piqued my interest.

## The task at hand

Sometime earlier this year, I gave my 7 year old daughter a repurposed Dell mini 9 running some flavor of Ubuntu.  My 6 year old daughter initally didn't care much about this. As the music played and programs were discovered, interest set in.  Pretty soon I would have to build another.  Having a few old laptops and small children in the mix, I suspected I would be rebuiliding these things a few times. Failures, accidents, upgrades, corruptions ... a potential time sink over time.

And .... any parent out there with small children close in age (or twins) can likely identify with my dilema. If both children don't get identical things, conflicts will arise. Similar toys, similar clothes, similar shoes .. sometimes the color, shape, and blinking lights must be identical. I am sure any difference in a laptop configuration would be noticed and eventually a point of contention. I needed these laptops to have identical functionality.

My 6 year old daughter started to insist on her own laptop as sharing one Dell Mini 9 was not really a workable solution. I had some Dell M620's in the pile so I upgraded ram, put in an inexpensive SSD, and started work to cook up a repeatable process to build the children's configuraion.

If you think about it, the task at hand seems ideal for a configuration managment system. I needed something to document what I was doing so it could be easily repeatable.

## Ansible to the rescue
I didn't try to set up a full-on PXE boot system to support an occasional laptop install. I wanted to teach my children to do some of the installation work for me (a different kind of automation, ha!). I decided to start from a minimal OS install and eventually broke down my Ansible approach into 3 parts: bootstrap, account setup, and software installation. I could have put everything into one giant script. Separting these functions allowed me to mix and match them for other projects and refine them individually over time. Ansible's yaml file readability helped to keep things clear as I refined my systems. For this laptop experiment, I decided on using Debian 32-bit as my starting point as it seemed to work best on my older hardware.

The bootstrap yaml script was intended to take a bare minimal OS install and bring it up to some standard. It relies on some non-root account being availble over SSH and little else. Sice a minimal OS install usually contains very little that is useful to ansible, I use the following to hit one host and prompt me for login with privilage escalation:
```
$ ansible-playbook bootstrap.yml -i '192.168.0.100,' -u jfarrell -Kk
```
The script makes use of the `raw` module to ensure some base requirements are set. It ensures Python is available, upgrades the OS, sets up an ansible control account, transferrs SSH keys, and configures sudo privelage escalation. When bootstrap is completed, everything should set in place to have this node fully participate in my larger ansible inventory. I've found that bootstrapping bare minimal OS installs is nuanced; if there is interest I'll write a specific article just on this topic.

The account yaml setup script is used to set up (or reset) user accounts for each family member. This keeps UID's/GID's consistant across the small number of machines we have, and can be used to fix locked accounts when needed. Yes, I know I could have set up NIS or LDAP authentication, but the number of accounts I have is very small and I preferred to keep these systems very simple. Here is an excerpt I found especially useful for this:
```
---
- name: Set user accounts
  hosts: all
  gather_facts: false
  become: yes
  vars_prompt:
    - name: passwd
      prompt: "Enter the desired ansible password:"
      private: yes

  tasks:
  - name: Add child 1 account
    user:
      state: present
      name: child1
      password: "{{ passwd | password_hash('sha512') }}"
      comment: Child One
      uid: 888
      group: users
      shell: /bin/bash
      generate_ssh_key: yes
      ssh_key_bits: 2048
      update_password: always
      create_home: yes
```
The `vars_prompt` section will prompt for a password, which is then put to a jinja2 transformation to procuce the desired password hash.  This way, I don't need to hardcode passwords into the yaml file and can run this in the future to change the passwords as needed.

The software installation yaml file is still evolving. It includes a base set of utilities for the sysadmin and then the stuff my users will rely on.  This mostly consists of ensuring the same GUI interface is installed along with all the same programs, games, and media files.  Here is a small excerpt of the software installed for my young children:
```
  - name: Install kids software
    apt:
      name: "{{ packages }}"
      state: present
    vars:
      packages:
      - lxde
      - childsplay
      - tuxpaint
      - tuxtype
      - pysycache
      - pysiogame
      - lmemory
      - bouncy
```

I put the effort into creating these 3 ansible scripts using a virtual machine. When they were perfect, it was tested on the new M620.  Once completed, converting the mini 9 was a snap; I simply loaded the same minimal Debian install, ran the bootstrap, accounts, and software configurations. Both systems then functioned identically.

For a while, both sisters enjoyed their respective computers, comparing usage, and exploring software fetures.

## The moment of truth
A few weeks later came the inevidable. My older daughter finally came to the conclusion that her pink Dell mini 9 was underpowered. Her sister's D620 had superior power and screen real estate. Youtube became the rage, and the mini 9 could not keep up. As you can guess, the poor mini 9 fell into disuse and she desired a new machine; sharing her sister's would not do.

I had anohter D620 in my pile. I replaced the BIOS battery, gave it a new SSD, upgraded RAM, and was ready to go. Another perfect example of breathing new life into old hardware.

I pulled my ansible scripts from source control, and everything I needed was right there. Bootstrap, account setup, and software install. By this time I had fogrotten much of the specific software installation information. Details like account UID's and all the packages to install were all cleary documented and ready for use. Surely I could have figured it out by spening time looking at my other machines, but no need! Ansible had it all clearly laid out in Yaml.

Not only was the yaml documentation valuable, but Ansible's automation made short work of the new install. I attempted to time some of my activities. The minimal Debian OS install from USB stick took about 15 minutes. The subsequent shape up of the system using Ansible for end-user deployment only took another 9 minutes. End user acceptiance testing was successful, and a new era of computing calmness was brought to my family (you parents will understand!).

## Conclusion

Taking the time to learn and practice Ansible through this exercise showed me the true value of its automation and documentation abilities.  A few hours figuring out the specifics for the first example saves me time whenever I need to provision or fix a machine. The Yaml is clear, easy to read, and thanks to Ansible's idempotency, easy to test and refine over time. When I have new ideas or requests from my children, using Ansible to control a local VM for my testing and scrutency is a valuable time saving tool.

Sysadmin tasks (during your free time) can be fun. Spending the time to automate and document your work pays rewards in the future; instead of having to investigate and re-learn a bunch of things you know you already solved, Ansible keeps your work documented and ready to apply so you can move onto other newer fun things!