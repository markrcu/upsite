# Successfully Build Php 5.6fpm & Apache 2.4 Protocol 2.0
##### `Build Size 562MB`
Follow the commands below to build the docker image successfully for Php5.6fpm & Apache 2.4. The Dockerfile is based on Amazon Linux AMI pulling from the remote repository (`FROM amazonlinux`) as selected before it starts packaging the required softwares and libraries for php and apache.
### Clone Repository
Run the command below to pull the docker file from Projects repository.
<br />
`Command:`
```
git clone git@gitlab.digitalroominc.com:mark.c/Projects.git
```
### Navigate to Projects directory
Run the command below to change directory to Protocol2/AmazonLinux/Uprinting/www folder.
<br />
`Command:`
```
cd Projects/Protocol2/AmazonLinux/Uprinting/www
```
### Docker Build and Run (Express) ``-Not Available-``
Run the command below to build and run the image. <br />
NOTE: The script will ask for the image name, containter name, and the host port bind the to container port. Wait until the "Instruction" message appear.
<br />
`Command:`
```
sh run.sh
```
### Docker Build and Run (Manual)
You can Build and Run the image manually by typing the command below
<br />
`Build Command:`
```
docker build -t www .
```
`Run Command:`
```
docker run -dit -p 80:80 -e NR_INSTALL_KEY="license_key" -e DOMAIN_NAME="www.uprinting.com" -e DOMAIN_STORE="store.uprinting.com" -e DOMAIN_PAYMENT="payment.uprinting.com" -e DOMAIN_DESIGN="design.uprinting.com" --name www www
```

##### To access the container's port using web browser(Chrome/Firefox) follow the instruction below
Will publish the container’s port(s) to the host port(s) that you entered a while ago<br />
You should be able to access the container using http://{YOUR_IP} and it should display the content below. <br />
`Display:`
```
File not Found!
