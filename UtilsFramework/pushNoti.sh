#!/bin/bash

isAllowPushNoti=1

#获取脚本路径
DIR="$( cd "$( dirname "$0" )" && pwd)"
echo ${DIR}



pushNotification(){
	diviceId="B9636DD6-81E8-4E33-8C57-9D81D47D3600"
	appName="com.opera.xxxx"
	pushFile="PushTest.apns"
	xcrun simctl push $diviceId $appName ${DIR}/${pushFile}
}

if [[ $isAllowPushNoti == 1 ]]; then
	pushNotification
fi