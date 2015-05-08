# CDH-Installer
-------------

####1. Introduction

	* This doc is written for describing how to use `install.sh` to deploy CDH to a new empty computer.
	* install.sh contains some steps to install CDH, like first to mkdir temp dirs , second to copy resolv file and so on.
	* install.sh also contains two mode -- testmode(TEST != 0) & realactionmode(TEST == 0). In testmode, we only copy files to local, but do not install them.
	* show steps of install.sh as below
		- step of mkdir tempdirs: It is necessary, so it will be done in both testmode & realactionmode.
		- step of environment: In this step, we copy resolv.conf, limits.conf, sysctl.conf files to local as Beginning of install. Also we backup olds.
		- step of installbase: In this step, we install jdk.
		- step of installcdh: In this step, we copy cdh source, and execute `yum -y install` to install CDH. Also copy configurations.
		- step of mkdata: In this step, we make dirs of hadoop temp.
		- step of createusers: In this step, we create users of cluster.
		- step of keytab: In this step, we copy keytab from nn1 to local.

####2. Install Operation
	
	* 2.1 copy install.sh & remote_scp_expect to computer which need to be install CDH. (samples: scp $LOCAL_DIR/install.sh $user@$host:$REMOTE_DIR/ , $REMOTE_DIR with no limits...)
	* 2.2 ssh to remote, use root user. (samples ssh root@$remote_host)
	* 2.3 check system environment whether current system has no CDH on that.(install.sh has no callback operations)
	* 2.4 if you has some quesitons, then you can set the param of TEST in install.sh to 1. It means execute install.sh in testmode, only copy files.
	* 2.5 execute install.sh as `install.sh all` under the dir of $REMOTE_DIR, then you can wait for the finish of CDH install.

####3. Notes
	
	* install.sh will copy remote source from nn1(38)&dn1(41) , so we must make sure new node can connecto to nn1 & dn1.
	* install.sh need remote_scp_expect to copy files from remote. So, make sure remote_scp_expect is in the parent dir of install.sh.
	* backup dir is under the runDir of install.sh, as `pwd`.

Good Luck~
----------
