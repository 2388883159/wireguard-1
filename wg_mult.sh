#！/bin/bash
#用于centos7+/ubuntu/debian的wireguard onekey脚本
函数 蓝色（）{
    echo -e " \033[34m\033[01m $1 \033[0m "
}
函数 绿色（）{
    echo -e " \033[32m\033[01m $1 \033[0m "
}
函数 红（）{
    echo -e " \033[31m\033[01m $1 \033[0m "
}

函数 rand(){
    最小 = 1 美元
    最大值 = $(( $2 - $min + 1 ))
    num= $( cat /dev/urandom | head -n 10 | cksum | awk -F '  '  ' {print $1} ' )
    回声 $(( $num % $max + $min ))  
}

函数 version_lt(){
    测试 “ $( echo " $@ "  | tr "  "  " \n "  | sort -rV | head -n 1 ) ” ！= “ $1 ”； 
}

函数 check_selinux(){

    检查= $( grep SELINUX= /etc/selinux/config | grep -v " # " )
    if [ " $CHECK "  ==  " SELINUX=enforcing " ] ;  然后
        红色“ ============ ”
        红色"关闭SELinux "
        红色“ ============ ”
        sed -i ' s/SELINUX=enforcing/SELINUX=disabled/g ' /etc/selinux/config
        设置强制 0
    菲
    if [ " $CHECK "  ==  " SELINUX=permissive " ] ;  然后
        红色“ ============ ”
        红色"关闭SELinux "
        红色“ ============ ”
        sed -i ' s/SELINUX=permissive/SELINUX=disabled/g ' /etc/selinux/config
        设置强制 0
    菲
}

函数 check_release(){

    源/etc/os-release
    发布= $ID
    版本= $VERSION_ID

}

功能安装 _工具（）{
    如果[ “ $RELEASE ”  ==  “ centos ” ] ； 然后
        $1 install -y qrencode iptables-services
        systemctl启用iptables
        systemctl 启动 iptables 
        iptables -F
	服务 iptables 保存
    别的
        $1 install -y qrencode iptables
    菲
    回声1 > /proc/sys/net/ipv4/ip_forward
    回声 “ net.ipv4.ip_forward = 1 ”  >> /etc/sysctl.conf
    sysctl -p

}

函数 install_wg(){
    check_release
    if [ “ $RELEASE ”  ==  “ centos ” ] && [ “ $VERSION ”  ==  “ 7 ” ] ； 然后
        yum install -y yum-utils epel-release
        yum-config-manager --setopt=centosplus.includepkgs=kernel-plus --enablerepo=centosplus --save
        sed -e ' s/^DEFAULTKERNEL=kernel$/DEFAULTKERNEL=kernel-plus/ ' -i /etc/sysconfig/kernel
        yum install -y kernel-plus wireguard-tools
        systemctl 停止 firewalld
        systemctl 禁用 firewalld
        安装工具“百胜”
    elif [ “ $RELEASE ”  ==  “ centos ” ] && [ “ $VERSION ”  ==  “ 8 ” ] ;  然后
        yum install -y yum-utils epel-release
        yum-config-manager --setopt=centosplus.includepkgs= "内核加，内核加-* " --setopt=centosplus.enabled=1 --save
        sed -e ' s/^DEFAULTKERNEL=kernel-core$/DEFAULTKERNEL=kernel-plus-core/ ' -i /etc/sysconfig/kernel
        yum install -y kernel-plus wireguard-tools
        systemctl 停止 firewalld
        systemctl 禁用 firewalld
        安装工具“百胜”
    elif [ “ $RELEASE ”  ==  “ ubuntu ” ] ； 然后
        if [ " $VERSION "  ==  " 12.04 " ] || [ “ $VERSION ”  ==  “ 16.04 ” ] ； 然后
	    红色“ ================== ”
            red " $RELEASE  $VERSION系统暂未支持"
            红色“ ================== ”
	    出口
	菲
        systemctl 停止 ufw
        systemctl 禁用 ufw
	apt-get install -y wget
	wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.8.15/amd64/linux-headers-5.8.15-050815-generic_5.8.15-050815.202010141131_amd64.deb
	wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.8.15/amd64/linux-headers-5.8.15-050815_5.8.15-050815.202010141131_all.deb
	wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.8.15/amd64/linux-image-unsigned-5.8.15-050815-generic_5.8.15-050815.202010141131_amd64.deb
	wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.8.15/amd64/linux-modules-5.8.15-050815-generic_5.8.15-050815.202010141131_amd64.deb
	dpkg -i * .deb
	apt-get -y 更新
        # apt-get install -y software-properties-common
        apt-get install -y openresolv
        # add-apt-repository -y ppa:wireguard/wireguard
        apt-get install -y 线卫
        安装工具“ apt-get ”
    elif [ “ $RELEASE ”  ==  “ debian ” ] ;  然后
        echo  " deb http://deb.debian.org/debian buster-backports main "  >> /etc/apt/sources.list
        # printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable
        适当更新
	apt install -y linux-image-5.8.0-0.bpo.2-cloud-amd64
	apt install -y wireguard openresolv
	#适当更新
        # apt install -y 线卫
        install_tools " apt "
    别的
        红色“ ================== ”
        red " $RELEASE  $VERSION系统暂未支持"
        红色“ ================== ”
    菲
}

函数 config_wg(){

    mkdir /etc/wireguard
    cd /etc/wireguard
    wg genkey | tee sprivatekey | wg pubkey > spublickey
    wg genkey | tee cprivatekey | wg 公钥> cpublickey
    s1= $(猫 sprivatekey )
    s2= $(猫 spublickey )
    c1= $(猫 cprivatekey )
    c2= $(猫 cpublickey )
    serverip= $( curl ipv4.icanhazip.com )
    端口= $（兰特10000 60000 ）
    eth= $( ls /sys/class/net | grep ^e | head -n1 )
    chmod 777 -R /etc/wireguard

cat > /etc/wireguard/wg0.conf << - EOF
[界面]
私钥 = OBlh/2Bm2vZPnXia2m3Yap8CK34+ojHRkkcqk3QAjnw=
地址 = 10.77.0.1/24 
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $eth -j 伪装
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $eth -j 伪装
监听端口 = 6666
DNS = 8.8.8.8
MTU = 1420
[同行]
公钥 = GYN9dZIVm2yVmQBL03vEpg//8hPmEahZUrzizQF5lng=
允许的 IP = 10.77.0.2/32
EOF

cat > /etc/wireguard/client.conf << - EOF
[界面]
私钥 = 0JPy8wEFTtiyzRMDx6XminE0ZMasrGLlZnN1fqg3TlM=
地址 = 10.77.0.2/24 
DNS = 8.8.8.8
MTU = 1420
[同行]
公钥 = Dvgav/xxemKv2uiTEAJid13NGaKplTI7RYJBgn+Dfgo=
端点 = $serverip:6666
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF
    # wg-quick up wg0
    systemctl启用wg-quick@wg0
    content= $( cat /etc/wireguard/client.conf )
    绿色《电脑端请下载/etc/wireguard/client.conf文件，手机端可直接使用软件扫码》
    绿色" ${content} "  | qrencode -o - -t UTF8
    red "注意：本次安装必须重启一次，wireguard 才能正常使用"
    read -p "是否现在重启？ [是/否] : " yn
    [ -z  " ${yn} " ] && yn= " y "
    如果[[ $yn  == [Yy] ]] ;  然后
        echo -e " VPS 重启中... "
        重启
    菲
}

函数 add_user(){

    绿色“ ================================== ”
    绿色“给新用户起个名字，不能和已有用户重复”
    绿色“ ================================== ”
    read -p "请输入用户名：" newname
    cd /etc/wireguard/
    如果[ ！ -f  " /etc/wireguard/ $newname .conf " ] ;  然后
        cp client.conf $newname .conf
        wg genkey | T 恤温度| wg pubkey > tempubkey
        ipnum= $( grep Allowed /etc/wireguard/wg0.conf | tail -1 | awk -F ' [ ./] '  ' {print $6} ' )
        newnum= $(( 10 # ${ipnum} + 1 ))
        sed -i ' s%^PrivateKey.*$% ' " PrivateKey = $( cat temprikey ) " ' % '  $newname .conf
        sed -i ' s%^Address.*$% ' "地址 = 10.77.0. $newnum \/24 " ' % '  $newname .conf
    cat >> /etc/wireguard/wg0.conf << - EOF
[同行]
PublicKey = $(cat tempubkey)
AllowedIPs = 10.77.0.$newnum/32
EOF
        wg set wg0 peer $( cat tempubkey ) allowed-ips 10.77.0. $newnum /32
        绿色“ ============================================== ”
        green "添加完成，文件：/etc/wireguard/ $newname .conf "
        绿色“ ============================================== ”
        rm -f 临时密钥临时密钥
    别的
        红色“ ====================== ”
        红色“用户名已存在，请更换姓名”
        红色“ ====================== ”
    菲

}

函数 remove_wg(){
    check_release
    if [ -d  " /etc/wireguard " ] ;  然后
        wg-快速下wg0
        如果[ “ $RELEASE ”  ==  “ centos ” ] ； 然后
            yum remove -y wireguard-dkms wireguard-tools
            rm -rf /etc/wireguard/
            绿色“卸载完成”
        elif [ “ $RELEASE ”  ==  “ ubuntu ” ] ； 然后
            apt-get remove -y 线卫
            rm -rf /etc/wireguard/
            绿色“卸载完成”
        elif [ “ $RELEASE ”  ==  “ debian ” ] ;  然后
            apt remove -y 线卫
            rm -rf /etc/wireguard/
            绿色“卸载完成”
        别的
            红色“系统不符合要求”
        菲
    别的
        红色“未检测到wireguard ”
    菲
}

函数 开始菜单（）{
    清除
    绿色“ =============================================== ”
    绿色“介绍：一键安装wireguard，增加wireguard多用户”
    绿色“系统：Centos7+/Ubuntu18.04+/Debian9+ ”
    绿色“作者：atrandys www.atrandys.com ”
    绿色“提示：脚本安装过程中会升级内核，不生产环境使用”
    绿色“ =============================================== ”
    绿色" 1. 安装wireguard "
    红色“ 2.删除wireguard ”
    绿色" 3. 显示默认用户二维码"
    绿色“ 4.增加用户”
    红色“ 0.退出”
    回声
    read -p "请选择：" num
    案例 “ $num ” 中
        1)
        check_selinux
        安装工作组
        config_wg
        ;;
        2)
        remove_wg
        ;;
        3)
        content= $( cat /etc/wireguard/client.conf )
        echo  " ${content} "  | qrencode -o - -t UTF8
        ;;
        4)
        添加用户
        ;;
        0)
        出口1
        ;;
        * )
        清除
        红色“请输入正确的数字！”
        睡眠 1 秒
        开始菜单
        ;;
        esac
}

开始菜单
