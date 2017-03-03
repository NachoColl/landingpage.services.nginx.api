#NGINX node.js API 

Node.js API to create/delete NGINX server configuration files.

Used from [https://landingpage.services](landingpage.services) to add custom domains support.

##How I use it

When I need landingpage.services to catch a new domain, I call the node.js API endpoint `api/cname` indicating the domain and the real page location. The node.js server then calls a bash script that creates the new NGINX sites-available server configuration file.


