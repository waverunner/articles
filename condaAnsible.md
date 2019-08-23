# Using Conda for Ansible Administration on MacOS
If you are a MacOS user starting out with Ansible administration, this article might be for you. It covers using the Conda package manager to help keep your Ansible work separate from your core OS and other local projects. Since the tools mentiond here are cross-platform, much of this article may apply to Linux with some parts working on Windows as well.

## Prelude
A few weeks ago I wanted to learn [Ansible](https://docs.ansible.com/?extIdCarryOver=true&sc_cid=701f2000001OH6uAAG) and so set out to figure out how I was going to install it.

 I am generally wary of installing things into my daily use workstation. I especially dislike applying manual updates to the vendor's default OS installation (a behavior I developed from years of UNIX system administration). I really wanted to use Python 3.7 (MacOS packages the older 2.7) and I was not going to install any global python packages that might interfere with the core MacOS system. I started my Ansible work using a local Ubuntu 18.04 virtual machine. This provided a real level of safe isolation but I soon found managing it to be tedious. I set out to see how I could have a flexible but isoalted Ansible system on native MacOS.

## Conda
Since Ansible is based on Python, Conda seemed to be ideal to manage it as well.

Conda is an open source utility that provides convenient package and environment management features. It can help you manage multiple versions of Python, install package dependencies, perform upgrades, and maintain project isolation. If you are manually managing Python virtual environments, Conda will help streamline and manage your work. Surf on over to the [Conda](https://conda.io/projects/conda/en/latest/index.html) documentation site for all the details.

In this case I am using the miniconda Python 3.7 installation for my workstation as I wanted the latest python version. Regardless of the version you select, you can always install new virtual environment with other desired versions of Python.

I downloaded the PKG format file, did the usual double-click, and performed the "Install for me only" option.  The install took about 158 MB of space on my system.

After the install, bring up a terminal to see what you have. You should see the following:
* a new `miniconda3` directory in your home
* shell prompt modified to prepend the word "(base)"
* `.bash_profile` updated with conda specific settings

Now the base is installed, but what do you have?  You now have your first Python virtual environment!   Running the usual python version check should prove this and your PATH will point to the new location:
```
(base) $ which python
/Users/jfarrell/miniconda3/bin/python
(base) $ python --version
Python 3.7.1
```
You can now use pip to install other desired packages, and start working on your new python virtual environment. Each time you bring up a new shell, it will default to this new base environment.

## Using Conda for Ansible management
Since Ansible is based on Python, we can use Conda to help us manage it. We can also use Conda to support multiple separate Python programming projects, and that also means you can separate your stable Ansible installtion from Ansible development.

Since I am also doing some small projects in Python I wanted to keep everything separate.  Conda has a number of sub commands you can use to create or clone a virtual environment, install and manage your packages, and destroy them when finished.  Here is a short list of the most useful Conda commands I typically use:
```
# Clone "base" to a new virtual environemnt
conda create -n newEnv --clone base             
# List all your virtual environments
conda env list                          
# Activate a different environment
conda activate newEnv
# install the python scipy package to current environment
conda install -n scipy                      
# Completely remove an environment
conda env remove -n newEnv              
```

So now for the fun part! I have a default base and want a separate environment to host my Ansible work. In most cases I would clone the base or another existing environment as a starting point. This is what I did:

```
$ conda create --name ansible --clone base
$ conda activate ansible
$ pip install ansible
$ conda env list
```

After this I have a new Conda environment called "ansible" that I can switch to whenever I want to do my Ansible work.  If I need to install python modules specific to supporting Ansible (like paramiko), you can easily install these to the new virtual environment keeping them separated from other projects. You can do this with either of the following
```
$ conda install --name ansible paramiko
$ pip install paramiko
```

Note: The Ansible documentation indicates you should use the --user option on pip for the install. If you do, Ansible will be loaded into `~/.local`, and you will need to do some fiddeling with your path to see the right bits.  A better way is to create the Conda environment and then do `pip install ansible` which installs to the "system location", which in this case is the Conda virtual environment.  After doing the installation, invoking `conda list` should show you all the installed packages including ansible, jinja2, etc.

Now, whenever you bring up a new terminal and need to use ansible, simply:

`$ conda activate ansible`

And then you can use ansible. If you have a clean ansible environment and want a new one to hack on for development purposes, you can create a new separate environment like this:
```
$ conda create --name ansible-dev --clone ansible
$ conda activate ansible-dev
```
 Once in your new Ansible development environment you can edit the ansible source or load unstable python modules and hack away.

## Conda trouble
Occasionally you may get into trouble with Conda. You can usually delete a bad environment with
```
$ conda activate base
$ conda remove --name newEnv --all
```
If you get errors that you think you cannot resolve, you can usually delete the environment directly by finding it in `~/miniconda3/envs` and removing the entire directory. It is possible for the base to become corrupt, in which case you can remove the entire `~/miniconda3` directory and then reinstall it from the PKG file. Just be sure to repserve any desired environments you have in `~/miniconda3/envs`, or use the conda tools to dump environment configuration that you can recreate later.

## Other tidbits: sshpass

Once I had my new Ansible environment, I checked my playbooks out of git and started testing.  Most were running fine until I tried some bootstrapping playbooks where I needed to manually enter passwords:

`$ ansible-playbook -i 'newhost,' ubuntu.yml -u jfarrell -Kk`

And I received the (abbreviated) error:
```
FAILED! => {"msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"}
```
After some digging I found that some Linux distributions like Ubuntu package the `sshpass` program by default. Centos 7 does not, but has it available via YUM for install. MacOS does not have this. Drat! I really want to use ansible-playbook -kK to prompt me for credentials when needed.

I have [Homebrew](https://brew.sh/) instlled on my Mac and naturally turned there for help:
```
$ brew search sshpass
We won't add sshpass because it makes it too easy for novice SSH users to
ruin SSH's security.
```
Well now the job just became more difficult. Searching for a solution I found brew recipes, but they seemed to refer to older sshpass versions and required other preinstalled utilities.

I found the current [sshpass source](https://sourceforge.net/projects/sshpass/) on sourceforge. Using Apple store I installed Xcode which gets a compiler, make, and other utilities installed. 

From there we expand the archive, run the configure script, run make and we are ready to go
```
$ tar zfvx sshpass-1.06.tar.gz
$ cd sshpass-1.06
$ ./configure --prefix=/usr/local
$ make
$ make install
```
If you don't trust the "make install", then simply take the `sshpass` binary produced by `make` and place it in your PATH where convenient. I compiled my on MacOS 10.12.6 and it also runs fine on 10.14.5.

Now we have the missing part and can use Ansible's ssh password prompting features.

## Conclusion
Ansible is a powerful automation utility, worth all the effort to learn. Conda is a simple and effective Python virtual environment management tool.

Keeping software installs separated on your MacOS environment is a prudent approach to maintain stability and sanity with your daily work environment.  Conda can be espcially helpful to upgrade your Python version, separate Ansible from your other projects, and safely hack on Ansible itself.

This article only touches upon the potential of these 2 utilities. I hope this inspires you to jump in and learn more.