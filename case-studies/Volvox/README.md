# Case study: Annotation of the _Volvox carteri_ genome
Contributed by Volker Brendel, February 2016.

To illustrate usage of __xGDBvm__, we'll go through complete annotation of a
moderately sized plant genome, that of the multicellular green algae _Volvox
carteri_.
This genome was deposited in NCBI in 2010 and consists of
[1,251 scaffolds totaling 137.7Mb](http://www.ncbi.nlm.nih.gov/assembly/166018).
The NCBI genome annotation comprises
[14,436 protein-coding genes](http://www.ncbi.nlm.nih.gov/genome/?term=Volvox)
and will serve as a point of comparison for the __xGDBvm__ annotation.
The singular green algae _Chlamydomonas reinhardtii_ provides a suitable
[reference annotation](http://www.ncbi.nlm.nih.gov/genome/?term=Chlamydomonas)
which was published three years earlier, thus exemplifying a typical use case
for __xGDBvm__ of generating an initial annotation and genome browser display
for a new genome based on comparison with a related, previously annotated species.

## Task 1:  Prepare an __xGDBvm__ instance

Log into [Atmosphere](https://atmo.iplantcollaborative.org/) and
[launch a new instance](https://atmo.iplantcollaborative.org/application#new_instance)
(a search for __xGDBvm__ in the _Select an Image_ field will show the latest
available __xGDBvm__ image).
For this study I use a _medium3_-sized instance.
Once deployed, I
[attach my usual _Volume_](https://pods.iplantcollaborative.org/wiki/display/atmman/Using+Volumes)
to the instance and
[ssh](https://pods.iplantcollaborative.org/wiki/display/atmman/Logging+In+to+an+Instance)
into the VM.
A first action is to customize the VM so that it looks to my liking.
As this is a recurrent task for every new instance, I keep my customized
_bash_ initiation scripts on the _Volume_ (mounted by default as /vol1) in a
directory named _util_.
I also set up the
[VNC](https://pods.iplantcollaborative.org/wiki/display/atmman/Launching+and+Terminating+a+VNC+Viewer+Session)
connection.
All this gets done conveniently by executing _/vol1/xstartover_, which invokes
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

followed by a reboot to use the latest kernel.

After the reboot, I connect to the VM via the recommended
[VNC standalone viewer](http://www.realvnc.com/download/viewer/).
To get the screen resolution I want, I issue (in a terminal window)

```
xrandr --screen 0 -s 1920x1080
```


__Note__: Depending on the particular VM image, you may skip the ssh step above
and access the VM directly using VNC, open a terminal window, and change the
resolution via the
[xrandr command](https://pods.iplantcollaborative.org/wiki/display/atmman/Changing+Screen+Resolution+for+the+VNC+Viewer).

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

### Task 3: Manage the __xGDBvm__ instance
Just like that, we are ready to view the home page of the web server our VM
has fired up.
As per instructions, I simply type the IP address Atmosphere assigned to my
VM into a web browser (to be clear,I do this on my laptop on a separate
desktop independent of my VNC connection; if I had a smart phone, that would
do fine, too; any browser, actually!).

On the __xGDBvm__ welcome screen, I follow the _Manage_ link, then
_Click to get started_ and the promising-sounding _Admin setup/secure_.
I am asked to set up passwords, and for now the simplest choice seems to be
_Option 2_, which password-protects the entire web server.

Even a seasoned user like I has had the experience of forgetting the
password rather too soon after setting it!
Not good, but not the end of the VM, either.
Go back to your ssh or VNC access terminal and type _quickstart_ again.
The last few lines displayed turned out to be relevant after all ... .

__Note__: The above pertains to a clean start with a _Volume_ that has not
retained prior __xGDBvm__ database files.
Otherwise, you can take advantage of the very nice feature of having _Volumes_
in the first place, as all your prior __xGDBvm__ work was saved on the
_Volume_ and can be detached from one VM and attached to a different VM,
carrying over all your prior work.

### Task 4: Getting sample data

```
xgetseq
```


### Task 5: Setting up the VcarTEST genome data base (GDB)

```
xsetup
```
