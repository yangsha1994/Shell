#!/bin/bash 
#explain：jdk和 tomcat 安装脚本
#author:yangyang

#
JDK_INSTALL_DIR="/xfdata/soft"
JDK_VERSION="1.8.0_181"

TOMCAT_INSTALL_DIR="/xfdata/soft"
TOMCAT_VERSION="8.5.45" 


function install_jdk(){

pushd ${JDK_INSTALL_DIR} 
#extract jdk(jdk 现在不能直接下载)
if [[ -f jdk-8u181-linux-x64.tar.gz  ]] 
then
    tar -xvf jdk-8u181-linux-x64.tar.gz
    #set environment
    export JAVA_HOME="${JDK_INSTALL_DIR}/jdk1.8.0_181"
    if ! grep "JAVA_HOME=${JDK_INSTALL_DIR}/jdk1.8.0_181" /etc/profile
    then
        echo "JAVA_HOME=${JDK_INSTALL_DIR}/jdk1.8.0_181" | sudo tee -a /etc/profile 
        echo "export JAVA_HOME" | sudo tee -a /etc/profile
        echo "PATH=$PATH:$JAVA_HOME/bin" | sudo tee -a /etc/profile 
        echo "export PATH" | sudo tee -a /etc/profile
        echo "CLASSPATH=.:$JAVA_HOME/lib" | sudo tee -a /etc/profile 
        echo "export CLASSPATH" | sudo tee -a /etc/profile

    else  
        echo "Please Download JDK."
        exit 1
    fi
fi
popd
#update environment
source /etc/profile  
ehco "JDK IS INSTALLED !"
}




function install_tomcat(){

pushd ${TOMCAT_INSTALL_DIR}
#install tomcat
[[ ! -f apache-tomcat-8.5.45.tar.gz ]]&&{
wget https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v8.5.45/bin/apache-tomcat-8.5.45.tar.gz
}
tar -xvf  apache-tomcat-8.5.45.tar.gz &>/dev/null 


#env
export CATALINA_HOME="${TOMCAT_INSTALL_DIR}/apache-tomcat-8.5.45"
if ! grep "CATALINA_HOME=${TOMCAT_INSTALL_DIR}/apache-tomcat-8.5.45" /etc/profile 
then 
    echo "export CATALINA_HOM=E${TOMCAT_INSTALL_DIR}/apache-tomcat-8.5.45" >> /etc/profile
fi 
popd

source /etc/profile

#service 
cat > /etc/init.d/tomcat << EOF
#!/bin/bash  
#chkconfig:112 63 37

JAVA_HOME=${JDK_INSTALL_DIR}/jdk1.8.0_181
PATH=\$JAVA_HOME/bin:\$PATH  
export JAVA_HOME
export PATH  
CATALINA_HOME=${TOMCAT_INSTALL_DIR}/apache-tomcat-8.5.45
#以上根据你自己的配置填写
case \$1 in  
start)  
sh \$CATALINA_HOME/bin/startup.sh  
;;   
stop)     
sh \$CATALINA_HOME/bin/shutdown.sh  
;;   
restart)  
sh \$CATALINA_HOME/bin/shutdown.sh  
sh \$CATALINA_HOME/bin/startup.sh  
;;   
esac      
exit 0
EOF
chmod +x /etc/init.d/tomcat
}

#run function 
$1

