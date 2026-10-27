#!/bin/sh
# ./ry.sh start 启动 stop 停止 restart 重启 status 状态
AppName=ruoyi-admin.jar

# 应用根目录 = 脚本所在目录 (jar 与脚本同目录), 与执行时的 cwd 无关
APP_HOME=$(cd "$(dirname "$0")" && pwd)
LOG_PATH=$APP_HOME/logs/$AppName.log

if [ ! -f "$APP_HOME/$AppName" ];
then
    echo -e "\033[0;31m $AppName not found in $APP_HOME \033[0m"
    exit 1
fi

# JVM参数 (JDK 17)
# JDK9+ 已移除 -XX:+PrintGCDateStamps / -XX:+PrintGCDetails，GC 日志改用 -Xlog
# JDK15+ 已移除 -XX:+UseParallelOldGC
JVM_OPTS="-Dname=$AppName -Duser.timezone=Asia/Shanghai -Xms512m -Xmx1024m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:NewRatio=1 -XX:SurvivorRatio=30 -XX:+UseParallelGC -Xlog:gc*:file=$APP_HOME/logs/gc.log:time,uptime,level,tags:filecount=5,filesize=10m"

if [ "$1" = "" ];
then
    echo -e "\033[0;31m 未输入操作名 \033[0m  \033[0;34m {start|stop|restart|status} \033[0m"
    exit 1
fi

if [ "$AppName" = "" ];
then
    echo -e "\033[0;31m 未输入应用名 \033[0m"
    exit 1
fi

function start()
{
    PID=`ps -ef |grep java|grep $AppName|grep -v grep|awk '{print $2}'`

    if [ x"$PID" != x"" ]; then
        echo "$AppName is running..."
    else
        mkdir -p "$APP_HOME/logs"
        cd "$APP_HOME" || exit 1
        nohup java $JVM_OPTS -jar $AppName > /dev/null 2>&1 &
        echo "Start $AppName success..."
    fi
}

function stop()
{
    echo "Stop $AppName"

    PID=""
    query(){
        PID=`ps -ef |grep java|grep $AppName|grep -v grep|awk '{print $2}'`
    }

    query
    if [ x"$PID" != x"" ]; then
        kill -TERM $PID
        echo "$AppName (pid:$PID) exiting..."
        while [ x"$PID" != x"" ]
        do
            sleep 1
            query
        done
        echo "$AppName exited."
    else
        echo "$AppName already stopped."
    fi
}

function restart()
{
    stop
    sleep 2
    start
}

function status()
{
    PID=`ps -ef |grep java|grep $AppName|grep -v grep|wc -l`
    if [ $PID != 0 ];then
        echo "$AppName is running..."
    else
        echo "$AppName is not running..."
    fi
}

case $1 in
    start)
    start;;
    stop)
    stop;;
    restart)
    restart;;
    status)
    status;;
    *)

esac
