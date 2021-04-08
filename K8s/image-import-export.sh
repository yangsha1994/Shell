
#!/bin/bash
#yangyang
#镜像导入导出
#$1=1 导入 ，$1=2 导出
# 参数匹配
# 地址

case $1 in
1)
ll $3|grep $2 |awk '{print $NF}'|sed -r 's#(.*)#docker load -i \1#' |bash
;;
2)
if [  $2 ] || [ $2 ==  'all' ];
then

docker  images |grep  $2 |while  read images
do
 imagesID=`echo $images |awk '{print $3}'`
 imagesname=`echo $images |awk '{print $1}'|awk -F '/' '{print $2}'`
 imagesversion=`echo $images |awk '{print $2}'`
 imagesfullname=`echo $images |awk '{print $1}'`:$imagesversion
 #导出
 docker save -o $imagesname-$imagesversion.tar $imagesfullname
done

fi
;;
*)
  echo "please inputargument: ./image-import-export.sh \$1 \$2 "
esac
