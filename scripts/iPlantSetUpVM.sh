#!/bin/bash

dataDir="/home/xgdb-data" #
dataLink="/xGDBvm/data"

inputDir="/home/xgdb-input" #
inputLink="/xGDBvm/input"

secure_flag="/xGDBvm/admin/https"
adminpassword="/xGDBvm/admin/adminpassword"
xgdbpassword="/xGDBvm/admin/xgdbpassword"


echo ""
echo "________________________________________________________________________________"
echo ""
echo "Initial setup"
echo "This script recreates some directories and settings that are required for xGDBvm"
echo "NOTE: Run this script whenever you create, resume, or reboot a VM."
echo ""
echo "________________________________________________________________________________"
echo ""




echo "########## Server Security and Configuration ###########"
echo ""
# 1. Prompt for password to secure site, if none is present (as indicated by password flag).

if [[ ! -f "$adminpassword"  && ! -f "$xgdbpassword" ]] # no flags present; user has not already protected either admin or whole site 
then
	while true; do
		echo ""
		echo "This VM should be password protected to limit Web access. The login username is 'user'."
		echo ""
		echo "Choose a login password you can share with others who may need to access your xGDBvm online (DO NOT use your iPlant password!)"; 
		echo ""
		echo "Enter a NEW password for 'user' (you can change it later online). Use 8 or more characters:";
		echo "Username: user"
		echo -n "Password: "
		read -s pw
		passlength=$(echo ${#pw})

		if [ $passlength -ge 8 ];
		then
			echo "Acceptable password"
			echo ""
			sudo /usr/bin/htpasswd -c -b /xGDBvm/.htpass_xgdb user $pw  # -c for create new; -b for batchwise
			sudo touch /xGDBvm/admin/xgdbpassword  # Add flag using root privilege (updated 1-22-15 to add sudo).
		break
		else
			echo ""; 
			echo "NOT ACCEPTED. Enter a longer password (>=8 characters):"
		fi
	done
	   success=$(egrep "$user\:.+" /xGDBvm/.htpass_xgdb)
	   if [ -n "$success" ]
	   then
		  echo ""
		  echo "Password protection is now in place for the Website. You will need to enter the username 'user' and your password when you access the VM online."
		  echo ""
		else
		  echo ""
		  echo "Password protection is NOT in place for the Website!!!! There may be a problem with this setup."
		  echo ""
	   fi
else
  echo "Web password: a password for 'user' is already in place for this VM."
  echo ""
fi

# 2. Update the .htaccess file (remove any existing) and replace with repository-updated version
if [ -f /xGDBvm/.htaccess ]
then
  sudo rm /xGDBvm/.htaccess
fi
sudo cp /xGDBvm/dist.htaccess /xGDBvm/.htaccess
if [ ! -f /xGDBvm/.htaccess ]
then
  echo ""
  echo "WARNING: An .htaccess file could not be created at /xGDBvm/.htaccess "
  echo ""
else
  echo "An updated .htaccess file has been created at /xGDBvm/.htaccess."
  echo ""
fi

#  3. Create default site name (server name)

if [ -f /xGDBvm/admin/sitename ] # if the sitename file exists (may or may not be empty)
then
sudo uname -n|cut -d "." -f 1 |tr '\n' ' ' > /xGDBvm/admin/sitename  # the VM's IP address. Overwrites any previous sitename.
sitename=$(uname -n|cut -d "." -f 1 |tr '\n' ' ' )
echo "The VM has been assigned the sitename $sitename"
echo ""
fi

# /sbin/ifconfig eth0 | grep inet | grep -v inet6 | awk '{print $2}' | cut -d ":" -f2 | tr -d "\n"> /xGDBvm/admin/sitename

# 4. Start ntpd (network time protocol daemon). Local ntp servers should already be configured in /etc/ntp.conf - if not, you can add them manually using sudo /usr/sbin/sntp -r [ntp.server.location]

/sbin/service ntpd start
echo ""
echo "We started the ntp daemon, which sets server clock to match local npt server (if configured)"
echo ""
dateTime=$(date +%Y-%m-%d\ %k:%M:%S)
echo "Current date and time:" $dateTime
echo " - If this does not match the time where your VM is hosted, check the xGDBvm wiki for troubleshooting instructions"
echo ""


# 5. Secure flag: When https is required on the VM (e.g. iPlant), this alerts certain configuration scripts 
#    to use an https:// URL when passing a URL variable.

if [ ! -f $secure_flag ]
then
  sudo touch $secure_flag
  echo ""
  echo "A secure server flag was created at /xGDBvm/admin/https."
  echo ""
else
  echo "A secure server flag is already present at /xGDBvm/admin/https."
  echo ""
fi

# 6. Start the Apache server

sudo /sbin/service httpd start

echo ""
echo "######### xGDBvm directory structure for input and output data ##########"
echo ""

#####  Input and Output Directories under /home (created ONLY if this is a NEW VM)

# 7. /home/xgdb-data

if [ ! -e $dataDir ]
then

  sudo mkdir $dataDir
  echo "$dataDir directory has been created."
  echo " - This directory will be mounted to an external volume for data output including mysql and tmp"
  echo ""
  chown -R root:xgdb $dataDir
  chmod -R 775 $dataDir
  echo "$dataDir directory permissions have been modified."
  echo ""
else
  echo ""
  echo "$dataDir directory already exists."
  echo " - This directory should be mounted to an external volume for data output including mysql and tmp"
fi
if [ ! -L /xGDBvm/data ]
then
  ln -s $dataDir $dataLink
  echo ""
  echo "$dataDir is now symlinked to $dataLink"
else
  echo ""
  echo "A symbolic link to $dataDir is already present at $dataLink."
  echo ""

fi

# 8. /home/xgdb-input

if [ ! -e $inputDir ]
then
  sudo mkdir $inputDir
  echo "$inputDir directory has been created."
  echo " - This directory will be mounted to user's Data Store for data input as well as remote job archives"
  echo ""
  chown -R root:users $inputDir
  chmod -R 775 $inputDir
  echo "$inputDir directory permissions have been modified."
  echo ""
else
  echo ""
  echo "$inputDir directory already exists."
  echo " - This directory should be mounted to user's Data Store for data input as well as remote job archives"
fi
if [ ! -L /xGDBvm/input ]
then
  ln -s $inputDir $inputLink
  echo ""
  echo "$inputDir is now symlinked to $inputLink"
  echo ""
else
  echo ""
  echo "A symbolic link to $inputDir is already present at $inputLink."
  echo ""
fi
  echo "Setup Complete! This VM is now set up to mount an external volume and user's Data Store."
  echo ""
  echo "Proceed to the next step as outlined under 'quickstart'"
  echo ""
  echo "##################   End of 'setup-vm' script ###################"
  echo ""

