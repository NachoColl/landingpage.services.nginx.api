var version = '1.5';

var express = require('express')
  , bodyParser = require('body-parser');
  
var app = express()

app.use(bodyParser.json());

app.get('/', function (req, res) {
  res.send('The landingpage.services NGNIX API version ' + version + ' is running and accesible to you :)')
})

// curl -d '{"domainName":"www.mydomain.com","identityId":"us-west-2:ca67320b-4d84-43bb-9347-7fcbfdf1a034"}' -H "Content-Type: application/json" http://localhost:8080/api/cname
app.post('/api/cname',function (req, res, next) {
    res.setHeader('Content-Type', 'application/json');
    
    if (req.hasOwnProperty("body") 
        && req.body.hasOwnProperty("action")
        && req.body.hasOwnProperty("parameters")
        && req.body.parameters.hasOwnProperty('domainName') && req.body.parameters.hasOwnProperty('identityId') 
        && req.body.parameters.hasOwnProperty('pageName') && req.body.parameters.hasOwnProperty('pageGuid')) {
        
        var sys  = require('util'),
            exec = require('child_process').exec,
            child;
         
        //e.g. 'create' or 'delete' 
        var action =  req.body.action;
        //e.g. "www.mydomain.com"  
        var domainName = req.body.parameters.domainName,
        //e.g. "us-west-2:ca67320b-4d84-43bb-9347-7fcbfdf1a034"
            identityId = req.body.parameters.identityId,
        //e.g. "my-page-name-without-extension"
            pageName = req.body.parameters.pageName,
        //e.g. "3423423423-23423-423-423423423"
            pageGuid = req.body.parameters.pageGuid,
        //e.g. "1" (1 indicates yes)
            defaultPage = '0';
        
        if (req.body.parameters.hasOwnProperty('defaultPage'))
            defaultPage = req.body.parameters.defaultPage;
    
        child = exec('sudo /usr/local/bin/nginx-add-server.sh ' + action + ' ' + domainName + ' ' + identityId + ' ' + pageGuid + ' ' + pageName + ' ' + defaultPage, function (error, stdout, stderr) 
        {
            if (error) {
               return res.status(500).send(JSON.stringify({ result: stdout}));
            }
    
            return res.status(200).send(JSON.stringify({ result: stdout}));
        });
    } else
        return res.status(400).send(JSON.stringify({ result: 'bad request'}));
})

app.listen(8080, function () {
  console.log('landingpage.services NGNIX API service listening on port 8080!')
})