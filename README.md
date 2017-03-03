#NGINX node.js API 

Node.js API to create/delete NGINX server configuration files.

Used from [https://landingpage.services](landingpage.services) to add custom domains support.

##How I use it

When I need landingpage.services to catch a new domain, I call the node.js API endpoint `api/cname` indicating the domain and the real page location. The node.js server then calls a bash script that creates the new NGINX configuration file.

NGINX server configuration file example:

```
server {
	listen   80;
      
  server_name www.trackphone.us;
      
	location = / {
		rewrite ^.* /gps-tracking-app.html; 
	}
      
	location / {
    proxy_pass https://s3-us-west-2.amazonaws.com/files.landingpage.services/us-west-2:1234sb-4f84-432b-96d7-7f54gdaa034/;
   }
}
```

The project is also available at cloud9 [https://c9.io/nachocoll/landingpage-services-nginx-api/](https://c9.io/nachocoll/landingpage-services-nginx-api/)


