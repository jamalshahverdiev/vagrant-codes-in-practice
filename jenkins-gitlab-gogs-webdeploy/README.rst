*********************************************
Jenkins with 2 slaves, Nexus, GitLab and GoGS
*********************************************

.. image:: https://cdn.rawgit.com/odb/official-bash-logo/master/assets/Logos/Identity/PNG/BASH_logo-transparent-bg-color.png


In this repository 'Vagrantfile' will deploy 6 machines: 

* Jenkins master (Same time Nexus)
* Jenkins slave node1
* Jenkins slave node2
* GitLab server
* GoGS server

You can take Jenkins **admin** password in the Jenkins master server from file **/var/lib/jenkins/secrets/initialAdminPassword**
Jenkins master server listens on port **8080** Nexus listens on port **8081**.

* Gogs admin login: **gogs**  
* Gogs admin login password: **gogspassword**

Generated SSH key private **gitlab** will be used from Jenkins master server to communicate to the slave servers.

=====
Usage
=====

* Just download repository and start virtual machines::

    # git clone https://github.com/jamalshahverdiev/jenkins-gitlab-gogs-webdeploy.git
    # cd jenkins-gitlab-gogs-webdeploy
    # ssh-keygen -b 2048 -t rsa -f gitlab -q -N ""
    # vagrant up


Note: Do not forget to change public adapter driver in the 'Vagrantfile' to your own name.
