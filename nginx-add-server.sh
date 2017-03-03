#!/bin/bash

### simplified version of https://github.com/RoverWire/virtualhost/blob/master/virtualhost-nginx.sh

### Parameters
action=$1
domain=$2
identityId=$3
pageGuid=$4
pageName=$5
defaultPage=$6


### Constants
owner=$(who am i | awk '{print $1}')
sitesEnable='/etc/nginx/sites-enabled/'
sitesAvailable='/etc/nginx/sites-available/'
landingpageServer='https://s3-us-west-2.amazonaws.com/files.landingpage.services/'

if [ "$(whoami)" != 'root' ]; then
	echo $"You have no permission to run $0 as non-root user. Use sudo"
		exit 1;
fi

if [ "$action" != 'create' ] && [ "$action" != 'delete' ]
	then
		echo $"You need to prompt for action (create or delete) -- Lower-case only"
		exit -1;
fi

if [ "$domain" == "" ]
then
	echo -e $"Please provide domain. e.g. 'www.mydomain.com'"
	exit -1;
fi

if [ "$pageName" == "" ]
then
	echo $"Please provide the page name without extension. e.g. 'my-page"
	exit -1;
fi

if [ "$pageGuid" == "" ]
then
	echo $"Please provide the page guid. e.g. '455463663-23423-243423-2434"
	exit -1;
fi

if [ "$action" == 'create' ]
	then
	
		### check parameters for create.
		if [ "$identityId" == "" ]
		then
			echo $"Please provide the user Identity Id. e.g. 'us-west-2:ca67320b-4d84-43bb-9347-7fcbfdf1a034'"
			exit -1;
		fi
		
		if [ "$defaultPage" == "" ]
		then
			echo $"Please indicate if default page ('1' or '0')"
			exit -1;
		fi

		### check if domain already exists
		if  -e $sitesAvailable$domain-$pageGuid ]; then
			echo $"This domain already exists!"
			exit -1;
		fi

		### Set default location
		if [ "$defaultPage" == "1" ] 
		then
			default="location = / {
				rewrite ^.* /$pageName.html; 
			}"
		else 
			default="" 
		fi
		
		### create virtual host rules file
		if ! echo "server {
			listen   80;
			server_name $domain;
			$default
			location / {
                proxy_pass $landingpageServer$identityId/;
            }
		}" > $sitesAvailable$domain-$pageGuid
		then
			echo $"There is an ERROR create $domain file"
			exit -1;
		else
			echo $"NGINX $domain server created."
		fi

		### enable website
		ln -s $sitesAvailable$domain-$pageGuid $sitesEnable$domain-$pageGuid

		### restart Nginx
		service nginx restart
		if [ $? -eq 0 ]; then
			### exit
			exit 0;
		else
			### remove de created server, just in case it's the cause for nginx restart fail.		   
			rm $sitesEnable$domain-$pageGuid
			service nginx restart
			rm $sitesAvailable$domain-$pageGuid
			
			echo $"Unable to restart NGINX. Please check parameters."
			exit -1;
		fi
	
	else
		### check whether domain already exists
		if ! [ -e $sitesAvailable$domain-$pageGuid ]; then
			echo $"This domain dont exists."
			exit -1;
		else
		
			### disable website
			rm $sitesEnable$domain-$pageGuid

			### restart Nginx
			service nginx restart

			### Delete virtual host rules files
			rm $sitesAvailable$domain-$pageGuid
		
			### exit	
			echo $"NGINX $domain server deleted for page $pageName"
			exit 0;
		fi
fi