# Case study: Annotation of the _Volvox carteri_ genome
Contributed by Volker Brendel, February 2016.

To illustrate usage of __xGDBvm__, we'll go through complete annotation of a
moderately sized plant genome, that of the multicellular green algae _Volvox
carteri_.
This genome was deposited in NCBI in 2010 and consists of
[1,251 scaffolds totaling 137.7Mb](http://www.ncbi.nlm.nih.gov/assembly/166018).
The NCBI genome annotation comprises [14,436 protein-coding genes](http://www.ncbi.nlm.nih.gov/genome/?term=Volvox) and will serve as a point
of comparison for the __xGDBvm__ annotation.
The singular green algae _Chlamydomonas reinhardtii_ provides a suitable
[reference annotation](http://www.ncbi.nlm.nih.gov/genome/?term=Chlamydomonas)
which was published three years earlier, thus exemplifying a typical use case
for __xGDBvm__ of generating an initial annotation and genome browser display
for a new genome based on comparison with a related, previously annotated species.

## Task 1:  Prepare an __xGDBvm__ instance

Log into [Atmosphere](https://atmo.iplantcollaborative.org/) and [launch a new instance](https://atmo.iplantcollaborative.org/application#new_instance) (a
search for __xGDBvm__ in the _Selecte an Image_ field will show the latest
available __xGDBvm__ image).
For this study I used a _medium3_-sized instance.
One deployed, I attached my usual _Volume_ to the instance and ssh'ed into the
VM.
A first action is customize the VM so that it looks to my liking.
As this is a recurrent task for every new instance, I keep my customized
_bash_ initiation scripts on the _Volume_ (mounted be default as /vol1) in a
directory name _util_.
I also set up the VNC connection to my liking.
All this get done conveniently by executing _/vol1/xstartover_, which invokes
the following commands listed in that file:

```
cd
\rm -rf Music Pictures Templates Videos

cp /vol1/util/bash_profile ~/.bash_profile
cp /vol1/util/bashrc ~/.bashrc
cp /vol1/util/bashrc_su ~/.bashrc_su

source .bash_profile

vncserver -kill :1
vncserver :1 -geometry 1920x1080
```

To be clear, none of these steps are necessary to invoke __xGDBvm__ functionality,
but the customization sure helps to make the VM my own.
For example, I am totally used to having the following aliases set in _.bashrc_,
and if I don't customize a new Linux environment in this way, I soon find
myself typing the familiar aliases in vain on the commandline:

```
alias cp='cp -i'
alias duh='du -H --max-depth=1'
alias find1d='find . -mtime -1 -print | more'
alias find2d='find . -mtime -2 -print | more'
alias find3d='find . -mtime -3 -print | more'
alias find3h='find . -mmin -180 -print | more'
alias home='clear; cd; echo "$HOSTNAME"; pwd; echo""; ls; echo""; date; echo ""'
alias lst='ls -lt'
alias lsf='ls -F'
alias mv='mv -i'
alias rm='rm -i'
alias sudobash='sudo bash -c "clear; echo \"$HOSTNAME\"; pwd; echo\"\"; ls; echo\"\"; date; echo\"\"; bash --rcfile ~$USER/.bashrc_su"'
alias swd='clear; echo "$HOSTNAME"; pwd; echo""; ls; echo""; date; echo""'
```

Lastly, I like to update the system packages installed on the VM:

```
sudobash
yum-complete-transaction
yum update
```

followed by a reboot to use the latest kernel.  Then I connect to the VM via
VNC.  To get the screen resolution I want I issue (in a terminal window)

```
xrandr --screen 0 -s 1920x1080
```

### Task 2: Configuring the __xGDBvm__ instance
The next step involves 1) following the instructions provided by typing
_quickstart_ at the command prompt, and 2) continuing with the set-up and
testing suggested by typing _instructions_ at the command prompt.
Using the VNC viewer, I find it convenient to have have one terminal window
open to view the instructions in summary and a second window to execute the
advised commands one by one.
It is rather helpful to go through the steps in this way rather than have even
more automated setup, as this way educates or reminds the user of the data sets,
conventions, and software being used.
