#!/bin/sh
##################################################################
################# install cdh in local  ##########################
##################################################################
TARGET=$1 ## install which module
EXPECT_TOOLS=`pwd` #dir of remote_scp_expect & ssh_expect
TEST=0 # 1 = open test mode, 0 = close test mode. In test mode , data will be copy to test dir & will not execute installing.
TEST_DIR=`pwd`/test
echo $TEST_DIR
BACKUP_DIR=backup
BACKUP_END=bak`date '+%Y%m%d-%H%M%S'`
BACKUP_LOG=info.bak
mkdir -p $BACKUP_DIR
##### handle dir param. ######
if [ $TEST -eq 0 ] ; then
        if [ "$TARGET" = "all" ] || [[ $TARGET = *resolv* ]] ; then
		### create back #####
		echo " backup /etc/resolv.conf" >> $BACKUP_LOG
		cp /etc/resolv.conf $BACKUP_DIR/resolv.conf.$BACKUP_END
		### copy /etc/resolv.conf ###a
                expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/resolv.conf" "/etc/"
	fi
        RPM_DIR=/root/rpm
	mkdir -p $RPM_DIR
        REPO_DIR=/etc/yum.repos.d
        HADOOP_CONF_DIR=/etc/
else
        RPM_DIR=$TEST_DIR/rpm
	mkdir -p $RPM_DIR
        REPO_DIR=$TEST_DIR/repo
	mkdir -p $REPO_DIR
        HADOOP_CONF_DIR=$TEST_DIR/
	OTHER_DIR=$TEST_DIR/other
	mkdir -p $OTHER_DIR
fi
###-----------------------------------------------------------###
######################### install jdk ###########################
###-----------------------------------------------------------###
if [ "$TARGET" = "all" ] || [[ $TARGET = *installbase* ]] ; then
        ## copy rpm to local ##
        echo "**************** STEP 1: to install jdk **************"
	## if jdk is right , then do nothing ##
	JAVA_INFO=`rpm -qa | grep jdk-1.7.0_60 `
	if [ ! -z $JAVA_INFO ] ; then
		echo "java1.7.0_60 has been installed - $JAVA_INFO. nothing has been done in STEP1 - installbase."
	else
	        JAVA_SOURCE=jdk-7u60-linux-x64.rpm
	        expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/root/rpm/$JAVA_SOURCE" $RPM_DIR/
	        echo "2.1 start install jdk"
	        if [ $TEST -eq 0 ] ; then
	                #update jdk.
	                jdks=`rpm -qa|grep jdk`
			echo $jdks >> $BACKUP_LOG
	                for jdk in $jdks
	                do
				echo "start to remove $jdk"
	                        rpm -e --nodeps $jdk
				if [ $? -eq 0 ] ; then
					echo $jdk" removed successfully."
				else
					echo $jdk" removed failed."
				fi
        	        done
                	rpm -ivh $RPM_DIR/$JAVA_SOURCE
	                expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/usr/java/jdk1.7.0_60/jre/lib/security/*.jar" "/usr/java/jdk1.7.0_60/jre/lib/security/"
	                echo "2.1 finished."
	        else
	                echo "2.1 nothing done"
        	fi
	fi
fi
###---------------------------------------------------------###
######################## install cdh ##########################
###---------------------------------------------------------###
if [ "$TARGET" = "all" ] || [[ $TARGET = *installcdh* ]] ; then
        echo "********  STEP 2: installing cdh.... **********"
        echo "3.1 copy cloudera-cdh5.repo & resolv.conf to local"
        expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/yum.repos.d/cloudera-cdh5.repo" $REPO_DIR/
	### backup rhel-source.repo ###
	cp $REPO_DIR/rhel-source.repo $BACKUP_DIR/rhel-source.repo.$BACKUP_END
        expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.41:/etc/yum.repos.d/rhel-source.repo" $REPO_DIR/
        if [ $TEST -eq 0 ] ; then
                echo "3.2 start to install cdh by yum"
                yum install -y hadoop-hdfs-datanode
                yum install -y hadoop-yarn
                yum install -y hadoop-yarn-nodemanager
                yum install -y hadoop-mapreduce
                yum install -y hbase-regionserver
		### backup hadoop-hdfs-datanode
		cp /etc/default/hadoop-hdfs-datanode $BACKUP_DIR/hadoop-hdfs-datanode.$BACKUP_END
                expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.41:/etc/default/hadoop-hdfs-datanode" "/etc/default/"
                echo "3.2 finished"
        else
                echo "3.2 nothing done"
        fi
        ######### copy hadoop-conf ##########
        echo "3.3 copy configuration to dest"
	echo "backup /etc/hadoop/conf & /etc/hbase/conf " >> $BACKUP_LOG
	cp /etc/hadoop/conf/core-site.xml $BACKUP_DIR/core-site.xml.$BACKUP_END
	cp /etc/hadoop/conf/hadoop-policy.xml $BACKUP_DIR/hadoop-policy.xml.$BACKUP_END
	cp /etc/hadoop/conf/mapred-site.xml $BACKUP_DIR/mapred-site.xml.$BACKUP_END
	cp /etc/hadoop/conf/yarn-site.xml $BAKCUP_DIR/yarn-site.xml.$BACKUP_END
	cp /etc/hadoop/conf/hdfs-site.xml $BACKUP_DIR/hdfs-site.xml.$BACKUP_END
	cp /etc/hadoop/conf/container-executor.cfg $BACKUP_DIR/container-executor.cfg.$BACKUP_END
	cp /etc/hbase/conf/hbase-env.sh $BACKUP_DIR/hbase-env.sh.$BACKUP_END
	cp /etc/hbase/conf/hbase-site.xml $BACKUP_DIR/hbase-site.xml.$BACKUP_END
	cp /etc/hbase/conf/zk-jaas.conf $BACKUP_DIR/jaas.conf.$BACKUP_END
	expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/hadoop/conf/core-site.xml" "/etc/hadoop/conf/"
	expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/hadoop/conf/hadoop-policy.xml"  "/etc/hadoop/conf/"
	expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/hadoop/conf/mapred-site.xml"   "/etc/hadoop/conf/"
	expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/hadoop/conf/yarn-site.xml"   "/etc/hadoop/conf/"
	expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/hadoop/conf/hdfs-site.xml"   "/etc/hadoop/conf/"
	expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/hadoop/conf/container-executor.cfg"   "/etc/hadoop/conf/"
	expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/hbase/conf/hbase-env.sh"   "/etc/hbase/conf/"
	expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/hbase/conf/hbase-site.xml"   "/etc/hbase/conf/"
	expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/hbase/conf/zk-jaas.conf"   "/etc/hbase/conf/"
        echo "********* installed cdh **************"
fi
###-----------------------------------------------------####
###### create data dir , yarn-local dir, yarn-log dir ######
###-----------------------------------------------------####
if [ "$TARGET" = "all" ] || [[ $TARGET = *mkdata* ]] ; then
        echo "************ STEP 3: MKDISK DIR OF DATA,YARN-LOCAL,YARN-LOG *****************"
        if [ $TEST -eq 0 ] ; then
        DISKIDS="2 3 4 5 6 7 8 9 10 11 12"
                for diskid in $DISKIDS
                do
                        if [ -d /hadoop_data/disk$diskid ] ; then
                                cd /hadoop_data/disk$diskid
                                mkdir data yarn-local yarn-log
                                chown hdfs:hdfs data
                                chown yarn:yarn yarn-log
                                chown yarn:yarn yarn-local
                        else
                                echo "/hadoop_data/disk$diskid does not exists "
                        fi
                done
        else
                echo "MKDISK DIR OF DATA,YARN-LOCAL,YARN-LOG in testmode ..... nothing done."
        fi
fi
###----------------------------------------------------------###
################ create users ##################################
###----------------------------------------------------------###
if [ "$TARGET" = "all" ] || [[ $TARGET = *createusers* ]] ; then
        echo " ********* STEP 4: to create users *********"
        if [ $TEST -eq 0 ] ; then
                useradd -g hadoop -u 5001 -d /home/john john
                useradd -g hadoop -u 5002 -d /home/eric eric
                useradd -g hadoop -u 5003 -d /home/benson benson
                useradd -g hadoop -u 5005 -d /home/khuaming khuaming
                useradd -g hadoop -u 5009 -d /home/wyanchang wyanchang
                useradd -g hadoop -u 5011 -d /home/xxke xxke
		useradd -g hadoop -u 5012 -d /home/zhuzhl zhuzhl
                useradd -g hadoop -u 6006 -d /home/qiujc qiujc
                useradd -g users -u 6001 -d /home/intone intone
		useradd -g users -u 6002 -d /home/cattsoft cattsoft
                useradd -g users -u 6003 -d /home/eastcom eastcom
                useradd -g users -u 6009 -d /home/pengxin pengxin
                useradd -g users -u 6004 -d /home/boco boco
                useradd -g hadoop -u 7000 -d /home/zhaocy zhaocy
                useradd -g hadoop -u 7001 -d /home/hush hush
                useradd -g hadoop -u 7002 -d /home/lizuoh lizuoh
                useradd -g hadoop -u 7003 -d /home/chengjm chengjm
                useradd -g hadoop -u 7004 -d /home/wangyz wangyz
                useradd -g hadoop -u 7005 -d /home/zhengyz zhengyz
                useradd -g hadoop -u 7006 -d /home/chendf chendf
                useradd -g hadoop -u 7007 -d /home/wangwd wangwd
                useradd -g hadoop -u 7008 -d /home/zhanght zhanght
                useradd -g hadoop -u 7009 -d /home/yulg yulg
                useradd -g hadoop -u 7011 -d /home/lixw lixw
                useradd -g hadoop -u 7012 -d /home/zhouhl zhouhl
                useradd -g hadoop -u 7013 -d /home/wuqx wuqx
                useradd -g hadoop -u 7014 -d /home/gulb gulb
                useradd -g hadoop -u 7015 -d /home/panyh panyh
                useradd -g hadoop -u 7016 -d /home/zhangjj zhangjj
                useradd -g hadoop -u 7019 -d /home/zhangr zhangr
                useradd -g hadoop -u 7020 -d /home/zhouy zhouy
                echo "************* user added***************"
        else
                echo "**************** no user added *************"
        fi
fi
##--------------------------------------------------------##
############## copy keytab to local ########################
##--------------------------------------------------------##
if [ "$TARGET" = "all" ] || [[ $TARGET = *keytab* ]] ; then
        echo "************ STEP 5: to install keytab **************"
        hostname=`hostname`
        echo $hostname
        if [ $TEST -eq 0 ] ; then
                expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/root/20141120/$hostname.hadoop.cmcc/$hostname.hadoop.cmcc.keytab" "/etc/hadoop/conf/"
                cd /etc/hadoop/conf
                cp *.hadoop.cmcc.keytab hdfs.keytab
                chown hdfs:hadoop hdfs.keytab
                chmod 600 hdfs.keytab
                cp *.hadoop.cmcc.keytab HTTP.keytab
                chmod 600 HTTP.keytab
                cp *.hadoop.cmcc.keytab mapred.keytab
                chmod 644 mapred.keytab
                cp *.hadoop.cmcc.keytab yarn.keytab
                chown yarn:hadoop yarn.keytab
                chmod 600 yarn.keytab
                expect $EXPECT_TOOLS/remote_scp_expect "2w:^gC{1" "-r" "root@192.168.30.38:/etc/krb5.conf" "/etc/"
        fi
fi
if [ "$TARGET" = "all" ] || [[ $TARGET = *test_install* ]] ; then
        echo "handle test_install"
fi

