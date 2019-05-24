#!/usr/bin/env bash
set -e

cd ${GOPATH}/src/github.com/AliyunContainerService/csi-plugin/
GIT_SHA=`git rev-parse --short HEAD || echo "HEAD"`

cp build/oss/csiplugin-connector.go build/all/csiplugin-connector.go
cp build/oss/csiplugin-connector-init build/all/csiplugin-connector-init
cp build/oss/ossfs_1.80.3_centos7.0_x86_64.rpm build/all/ossfs_1.80.3_centos7.0_x86_64.rpm

export GOARCH="amd64"
export GOOS="linux"

branch="v1.0.0"
version="v1.13.2"
commitId=$GIT_SHA
buildTime=`date "+%Y-%m-%d-%H:%M:%S"`

CGO_ENABLED=0 go build -ldflags "-X main._BRANCH_='$branch' -X main._VERSION_='$version-$commitId' -X main._BUILDTIME_='$buildTime'" -o plugin.csi.alibabacloud.com

cd ${GOPATH}/src/github.com/AliyunContainerService/csi-plugin/build/all/
CGO_ENABLED=0 go build csiplugin-connector.go

if [ "$1" == "" ]; then
  mv ${GOPATH}/src/github.com/AliyunContainerService/csi-plugin/plugin.csi.alibabacloud.com ./
  docker build -t=registry.cn-hangzhou.aliyuncs.com/plugins/csi-plugin:$version-$GIT_SHA ./
  docker push registry.cn-hangzhou.aliyuncs.com/plugins/csi-plugin:$version-$GIT_SHA
fi