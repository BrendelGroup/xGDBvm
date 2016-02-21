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

One more item remains to be taken care of: _Manage_ -> _Configure/Create_ ->
_License Keys_ gives instructions on how to update licenses for some of the
programs being used.
This is made as painless as possible, and the programs are well worth the
little additional first-time effort they (currently) require for use.

__Note__: The above pertains to a clean start with a _Volume_ that has not
retained prior __xGDBvm__ database files.
Otherwise, you can take advantage of the very nice feature of having _Volumes_
in the first place, as all your prior __xGDBvm__ work was saved on the
_Volume_ and can be detached from one VM and attached to a different VM,
carrying over all your prior work.


### Task 4: Running an example on my __xGDBvm__ instance
Just to make sure that all is working all right, I typically run one of the
provided examples.
On the web site of the instance, follow _Manage_ -> _Configure/Create_ ->
_Configure New GDB_ -> _EXAMPLE DATASETS_.
_EXAMPLE 4_ will do nicely.
_Data Process Options_ offers to _Validate Inputs_, and I am in the habit of
clicking that button to not waste time later on something as trivial as not
having supplied valid FASTA-formatted files, for example.
Then _Create Database_ does the job.
I check the output, and if there is nothing amiss, I delete the example
database to keep my VM tidy: _Manage_ -> _Configure/Create_ ->
_Archive/Delete GDB_ (really optional; as a new user you may want to keep the
example active for quick reference).


### Task 5: Getting sample data
Now that my new __xGDBvm__ instance is all prepared and tested for functionality,
it is time to get it to work on my case study data.
For my own records and for the sake of reproducibility, the file _xgetseq_ in
this folder contains the exact commands used to download the sequence sets
mentioned in the opening paragraph.
To reproduce this case study, you may want to execute the following commands
on your VM:

```
cd /home/xgdb-data/
mkdir prj
cd prj
mkdir Volvox
cd Volvox
cp /xGDVvm/case-studies/Volvox/* ./
xgetseq
```

What did we do and what is the result?
First, we created a _prj_ directory on our _Volume_ with subdirectory _Volvox_.
We then copied the contents of this _github_ directory into that subdirectory,
taking advantage of the fact that you already have a clone of the _github_
repository under _/xGDBvm_ on your VM!
(At first, this may get rather confusing  - talking about the _github_ repository,
the VM as your own machine accessed via _ssh_ or _VNC_, and the web interface
of the __xGDBvm__ instance!  But you can easily open all these views in different
windows on your screen, and soon this will be very familiar ...).

__Note__: If you want to follow this example, you will have to additionally
download the _Volvox_ ESTs as per instructions in the _xgetseq_ file.
In order to test our approach, it's always good to run sample data first.
Here, the _case-studies/Volvox_ directory contains files _VcarrTEST.gdna.fa_,
_VcarTEST.annot.gff3_, and _VcarTEST.est.fa_.
The first two of these files contain only one _Volvox carteri_ scaffold and its
NCBI annotation, and the EST files contains only about a quarter of the entire
EST set.
We'll use these test sets first.

## Task 6: Setting up the VcarTEST genome data base (GDB)
There is one more step to take before configuring our GDBs via the web interface.
You can use the script _xsetup_ in this folder to copy the relevant data for both
the _VcarTEST_ and the complete _Vcar_ runs into folders on the data store
mounted as _home/xgdb-input_, subdirectory _xdgdbvm_.
These are the places where we'll instruct the code to look for input data when
we configure the GDBs.
Also, _CRprot.fa_ will be used as a reference protein set and should be placed
in the _/xGDBvm/input/xgdbvm/referenceprotein/_ folder.

```
mkdir /xGDBvm/input/xgdbvm/VcarTEST
cp Vcar.annot.gff3 Vcar.annot.mrna.fa Vcar.annot.pep.fa VcarTEST.est.fa VcarTEST
.gdna.fa  CRprot.fa  /xGDBvm/input/xgdbvm/VcarTEST

mkdir /xGDBvm/input/xgdbvm/Vcar
cp Vcar.annot.gff3 Vcar.annot.mrna.fa Vcar.annot.pep.fa Vcar.est.fa Vcar.gdna.fa
  CRprot.fa  /xGDBvm/input/xgdbvm/Vcar

cp CRprot.fa /xGDBvm/input/xgdbvm/referenceprotein/

```

## Task 7: Configuring our new GDBs
All the next and fun part of the work is done via the web interface to our
__xGDBvm__ instance.
Go again to _Manage_ -> _Configure/Create_ -> _Configure New GDB_, but now instead
of using example data sets, we'll use the _Volvox carteri_ data.
