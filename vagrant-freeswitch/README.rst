Just clone repo and install the following plugins and then start.



**********************************************************************************
Install and start FreeSWITCH for CentOS7
**********************************************************************************

.. image:: https://img.shields.io/codecov/c/github/codecov/example-python.svg

Requirements:
    **Vagrant** and **Virtualbox** must be installed to the Windows desktop
        

Install needed vagrant plugins to the Windows desktop in the GitBash console:

.. code-block:: bash

    $ vagrant plugin install vagrant-winnfsd
    $ vagrant plugin install vagrant-berkshelf
    $ vagrant plugin install vagrant-hostmanager
    $ vagrant plugin install vagrant-hostsupdater
    $ vagrant plugin install vagrant-omnibus
    $ vagrant plugin install vagrant-share
    $ vagrant plugin install vagrant-reload
..


* Clone the repo and go inside of the Freeswitch vagrant folder and start the deployment:

.. code-block:: bash

    $ git clone https://github.com/jamalshahverdiev/vagrant-codes-in-practice.git && cd vagrant-freeswitch
    $ vagrant up
..
