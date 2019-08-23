# Managing Ansible environments on MacOS with Conada
If you are a Python developer using MacOS and involved with Ansible administration, this article might be for you. It covers using the Conda package manager to help keep your Ansible work separate from your core OS and other local projects. 

Ansible is based on Python. Conda is not required to make Ansible work on MacOS. Conda does however, make managing Python versions and package dependencies easier. This allows you to use an upgraded Python version on MacOS and keep Python package dependencies separated between your system, Ansible, and other programming projects you have.

There are other ways to install Ansible. You could use [Homebrew](https://brew.sh/) if all you are interested in is Ansible use.  However, if you are into Python development (or even Ansible development), you might want to reduce some confusion by managing Ansible in a Python virtual environment.  For me I find this to be simpler. Rather than trying to load a Python version and dependencies into the system or in /usr/local, Conda helps me corrale everything I need for Ansible into a virtual environment and keep it all completely separate from other projects.

This article focuses on using Conda to manage Ansible as a Python project to keep it clean and separated from other projects. We will install Conda, create a new virtual environment, install Ansible, and test it.


## Prelude
A few weeks ago I wanted to learn [Ansible](https://docs.ansible.com/?extIdCarryOver=true&sc_cid=701f2000001OH6uAAG) and so set out to figure out how I was going to install it.

 I am generally wary of installing things into my daily use workstation. I especially dislike applying manual updates to the vendor's default OS installation (a behavior I developed from years of UNIX system administration). I really wanted to use Python 3.7 (MacOS packages the older 2.7) and I was not going to install any global python packages that might interfere with the core MacOS system. I started my Ansible work using a local Ubuntu 18.04 virtual machine. This provided a real level of safe isolation but I soon found managing it to be tedious. I set out to see how I could have a flexible but isoalted Ansible system on native MacOS.

## Installing Conda
Since Ansible is based on Python, Conda seemed to be ideal to manage it as well.

Conda is an open source utility that provides convenient package and environment management features. It can help you manage multiple versions of Python, install package dependencies, perform upgrades, and maintain project isolation. If you are manually managing Python virtual environments, Conda will help streamline and manage your work. Surf on over to the [Conda](https://conda.io/projects/conda/en/latest/index.html) documentation site for all the details.

In this case I am using the miniconda Python 3.7 installation for my workstation as I wanted the latest python version. Regardless of the version you select, you can always install new virtual environments with other desired versions of Python.

I downloaded the PKG format file, did the usual double-click, and performed the "Install for me only" option.  The install took about 158 MB of space on my system.

After the install, bring up a terminal to see what you have. You should see the following:
* a new `miniconda3` directory in your home
* shell prompt modified to prepend the word "(base)"
* `.bash_profile` updated with conda specific settings

Now the base is installed, but what do you have?  You now have your first Python virtual environment.   Running the usual python version check should prove this and your PATH will point to the new location:
```
(base) $ which python
/Users/jfarrell/miniconda3/bin/python
(base) $ python --version
Python 3.7.1
```
Now that Conda is installed, let's set up a virtual enviroment and follow that with getting Ansible installed and running.

## Creating a virtual environment for Ansible
I want to keep Ansible separate from my other Python projects, so I create a new virtual environment and switch over to it:
```
(base) $ conda create --name ansible-env --clone base
(base) $ conda activate ansible-env
(ansible-env) $ conda env list
```
The first command clones the Conda base into a new virtual environmet called ansible-env. The clone brings in the Python 3.7 version and a bunch of default Python modules that I can add to, remove, or upgrade as needed.

The second command actually changes the shell context to this new ansible-env environment. It sets the proper paths for Python and the modules it contains.

Notice that your shell prompt changes after the `conda activate ansible-env` command.

The 3rd command is not required, it lists what Python modules are installed with their version and other data.

You can always switch out of a virtual environment and into another with Conda's activate command. This will bring you back to the base: `conda activate base`

## Installing Ansible
Ansible can be installed by various methods, but I chose to use Conda to keep the Ansible version and all desired dependencies packaged in one place. Conda gives the flexibility here to keep it all separated and to add in other new environments as needed (which we'll see later).

To install a relaitvely recent version of Ansible use:

```
(base) $ conda activate ansible-env
(ansible-env) $ conda install -c conda-forge ansible
```

Since Ansible is not part of Conda's default channels, the `-c` is used to search and install from an alternate channel. Ansible is now installed into the "ansible-env" virtual environment and ready to use.

## Using Ansible
Now that you have a Conda virtual environment installed, Let's use it!  First, make sure the node you wish to control has the SSH key of your workstation installed to the necessary user account.

Bring up a new shell and run some basic Ansible commands:
```
(base) $ conda activate ansible-env
(ansible-env) $ ansible --version
ansible 2.8.1
  config file = None
  configured module search path = ['/Users/jfarrell/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /Users/jfarrell/miniconda3/envs/ansibleTest/lib/python3.7/site-packages/ansible
  executable location = /Users/jfarrell/miniconda3/envs/ansibleTest/bin/ansible
  python version = 3.7.1 (default, Dec 14 2018, 13:28:58) [Clang 4.0.1 (tags/RELEASE_401/final)]
(ansible-env) $ ansible all -m ping -u ansible
192.168.99.200 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

Now that Ansible is working, you can pull your playbooks out of source controll and start using them from your MacOS workstation.

## Cloning your new Ansible for Ansible development
This part is purely optional, and only needed if you want additional virtual environments to modify Ansible itelf, or safely experiment with questionable Python modules. You can clone your main Ansible environment into a development copy by using:
```
(ansible-env) $ conda create --name ansible-dev --clone ansible-env
(ansible-env) $ conda activte ansible-dev
(ansible-dev) $
```

## Gotchas to look out for
Occasionally you may get into trouble with Conda. You can usually delete a bad environment with
```
$ conda activate base
$ conda remove --name ansible-dev --all
```
If you get errors that you think you cannot resolve, you can usually delete the environment directly by finding it in `~/miniconda3/envs` and removing the entire directory. It is possible for the base to become corrupt, in which case you can remove the entire `~/miniconda3` directory and then reinstall it from the PKG file. Just be sure to preserve any desired environments you have in `~/miniconda3/envs`, or use the conda tools to dump environment configuration that you can recreate later.

The `sshpass` program is not inclued on MacOS. This is only needed if your Ansible work requires you to supply Ansible with SSH login password. You can find the current [sshpass source on sourceforge.com](https://sourceforge.net/projects/sshpass/)

Finally, the base Conda Python module list may lack some Python modules you'll need for your work. The `conda install <package>` command is preferred, but `pip` can be used where needed, and Conda will recognize the install modules.


## Conclusion
Ansible is a powerful automation utility, worth all the effort to learn. Conda is a simple and effective Python virtual environment management tool.

Keeping software installs separated on your MacOS environment is a prudent approach to maintain stability and sanity with your daily work environment.  Conda can be espcially helpful to upgrade your Python version, separate Ansible from your other projects, and safely hack on Ansible itself.

This article only touches upon the potential of these 2 utilities. I hope this inspires you to jump in and learn more.
