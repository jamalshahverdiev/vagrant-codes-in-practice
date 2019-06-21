#### These codes install and configure Nexus repository server
##### Just download all code files and start them with the following commands:
```bash
$ git clone https://github.com/jamalshahverdiev/vagrant-codes-in-practice.git && cd vagrant-codes-in-practice/vagrant-nexus
$ vagrant up
```
The **scripts/install.sh** script contains needed packages to be install and JAVA/MAVEN environment variables.

The **scripts/mvncompile.sh** script create new Java app with name __newapp__ and the build/package it. Prepared package will be in the __target/__ folder.

The **scripts/nexusinstall.sh** script install/configure Nexus repository server.

The **scripts/createrepoUploadartifacts.sh** script gets 3 arguments, first argument - the new username of the Nexus server, second argument - the IP address of the Nexus server, third argument - reporitory name which will be created in the Nexus server. Script will POST **user.xml** (to create new username) and **hostedrepo.json** (to create new repository) files to the Nexus repository via API. At the end it will upload new created JAVA application to the new repository with the new username and password. If you want download artifact from the repository just use the last line. The templates stored in the __scripts/temps__ folder.
