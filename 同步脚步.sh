#/bin/bash



huanjinganzhuang(){
clear;
sleep 1
if [ ! -f "/usr/bin/axel" ]; then
            echo "没有安装AXEL多线程下载工具，开始安装..."
			yum install axel -y >/dev/null 2>&1
			fi
if [ ! -f "/usr/bin/python3" ]; then
            echo "没有安装Python3运行环境，开始安装..."
			yum install python3 -y >/dev/null 2>&1
			fi
            echo -e "\033[41;37m 环境检查完毕，应该可以正常运行了吧QAQ \033[0m"
            sleep 3
            bash $0;
}

mashangtongbu(){
sleep 1
clear;
pkill python3
pkill axel
rm -rf ./xiazaiwenjian.sh >/dev/null 2>&1
rm -rf /Tongbumulu/axel.log >/dev/null 2>&1
echo "爬取文件名并追加下载命令及地址..."
sleep 1
python3 tongbu.py 2>&1 | tee xiazaiwenjian.sh
echo "完成"
sleep 1
echo "开始下载..."
sleep 1
starttime=`date +'%Y-%m-%d %H:%M:%S'`
bash xiazaiwenjian.sh
echo "同步停止QAQ..."
time3=$(date "+%Y-%m-%d %H:%M:%S")
echo "同步完成，请自行检查文件完整性! @同步开始时间：${starttime} 结束时间;${time3}" 2>&1 | tee /Tongbumulu/axel.log
rm -rf ./xiazaiwenjian.sh >/dev/null 2>&1
exit;
}
meitianliangdiantongbu(){
yum install crontabs -y >/dev/null 2>&1
systemctl enable crond >/dev/null 2>&1
systemctl start crond >/dev/null 2>&1
echo "写入同步命令..."
sleep 1
echo "0 2 * * * root /root/$0 -t >> /tmp/tmp.txt" >> /etc/crontab
echo "加载同步任务..."
crontab /etc/crontab >/dev/null 2>&1
echo "完成啦QAQ"
exit;
}



Main(){
cd /
mkdir Tongbumulu >/dev/null 2>&1
cd ~
source ~/.bashrc
sleep 2
clear;
echo "----------------------------------"
echo -e "\033[41;37m 欢迎使用橙狐Recovery Redmi Note7 PRO 同步脚本 \033[0m"
echo -e "\033[41;37m 同步完成的信息在/Tongbumulu下的axe.log有记录 \033[0m"
echo -e "\033[41;37m 由于作者不怎么会编程，所以做得可能不怎么好 \033[0m"
echo -e "\033[41;37m 当然，开源那是肯定的，不过感觉没什么用QAQ \033[0m"
echo -e "\033[41;37m 开源地址:  \033[0m"
echo "(1) 安装脚本所需环境"
echo "(2) 马上同步文件"
echo "(3) 每天2:00同步文件(root)"
echo "(4) 功能4 "
echo "(5) 退出脚本"
echo "----------------------------------"
read input
case $input in
    1)
    echo "环境检查"
    sleep 1
    huanjinganzhuang;;
    2)
    echo "开始同步QAQ"
    mashangtongbu;;
    3)
    echo "设置执行"
    sleep 1
    meitianliangdiantongbu;;
    4)
    echo "运行功能4 额! 这个功能作者没开发。"
    sleep 1
    bash $0;;
    5)
    exit;;
    *)
    echo -e "\033[41;37m 错误数字 \033[0m"
    sleep 2
    bash $0;;
esac
}

while [ $1 ]; do
	case $1 in
		'-t' | '--tongbu' )
			mashangtongbu
			exit
			;;
	esac
	shift
done
Main