# tserver1423
#### 准备

1. docker安装，参考之前[docker中部署开源的接口管理工具doclever](https://segmentfault.com/a/1190000037686658)中的docker安装部分，本篇环境wsl2的ubuntu系统。
2. 泰拉瑞亚服务端文件，下载地址[泰拉瑞亚服务端](https://terraria.org/api/download/pc-dedicated-server/terraria-server-1423.zip)，如果链接失效，可以百度**泰拉瑞亚官网**找下载。

#### 构建

1. 准备一个临时文件夹，将下载的服务端文件解压后，只需要copy linux版本进来就行。

   ```shell
   $ mkdir temp
   # 给这个文件加上执行权限
   $ chmod +x linux/TerrariaServer.bin.x86_64
   $ cp linux temp/linux
   ```

2. 创建Dockerfile，与linux同级目录

   ```shell
   $ vim Dockerfile
   ```

3. 编辑Dockerfile

   ```dockerfile
   # 声明基础镜像，我这里用的ubuntu，大概80m
   FROM ubuntu:latest AS base
   # 在COPY命令后，改变容器的默认路径，这里直接进入到游戏文件根目录
   WORKDIR /usr/local/tserver
   # 未来暴露7777端口，因为泰拉瑞亚服务端端口默认7777，没特殊必要不需要修改
   EXPOSE 7777
   # 将本地游戏文件复制到ubuntu的路径下
   COPY ./linux /usr/local/tserver 
   # 当容器运行后执行的开服命令
   # ./TerrariaServer.bin.x86_64   可执行文件
   # -config 指定游戏配置文件
   # serverconfig.txt 游戏服务器配置文件
   ENTRYPOINT ["./TerrariaServer.bin.x86_64","-config","serverconfig.txt"]
   ```

4. 创建游戏服务器配置文件，在linux目录下，与游戏文件同级

   ```shell
   $ vim serverconfig.txt
   ```

   文件放到文章的最后，配置根据需要自行修改，我这里配置的是：

   1. 指定地图名称 *TerrariaMaster1423.wld*

   2. 指定地图加载路径 *./Worlds/*

   3. 端口 7777

   4. 服务器密码 1423

   5. 最大玩家数 8人

   6. 地图难度 大师级

   7. 地图尺寸 小型

      ...

5. 一切准备就绪，构建开始

   ```shell
   # 不要忘记末尾有个句点，这是表示从当前目录寻找Dockerfile
   $ docker build -t 1423_master_smallworld:v1 . 
   ```

#### 开黑

1. 测试启动

   ```shell
   $ docker run --rm -it 1423_master_smallworld:v1
   ```

2. 正式启动

   ```shell
   # -d 后台运行
   # --rm 当容器停止后删除容器
   # -p 端口映射到物理机
   # -v 卷映射，将游戏存档持久化到物理机硬盘上
   $ docker run -it --rm -p 7777:7777 -v /home/xsf/temp/Worlds:/usr/local/tserver/Worlds 1423_master_smallworld:v1 
   ```
   **至于为什么一定需要 -it 而不是 -d 至于后台启动，因为游戏服务的限制，必须前置终端输出，否则会启动失败
   如果需要在远程服务器上启动，需要用screen或tmux配合启动，因为当关闭远程后，服务会自动关闭（没有守护进程**
#### 后记

1. 游戏服务器配置文件(参考)

   ```
   #this is an example config file for TerrariaServer.exe
   #use the command 'TerrariaServer.exe -config serverconfig.txt' to use this configuration or run start-server.bat
   #please report crashes by emailing crashlog.txt to support@terraria.org
   
   #the following is a list of available command line parameters:
   
   #-config <config file>				            Specifies the configuration file to use.
   #-port <port number>				              Specifies the port to listen on.
   #-players <number> / -maxplayers <number>	Sets the max number of players
   #-pass <password> / -password <password>		Sets the server password
   #-world <world file>					Load a world and automatically start the server.
   #-autocreate <#>					Creates a world if none is found in the path specified by -world. World size is specified by: 1(small), 2(medium), and 3(large).
   #-banlist <path>					Specifies the location of the banlist. Defaults to "banlist.txt" in the working directory.
   #-worldname <world name>             			Sets the name of the world when using -autocreate.
   #-secure						Adds addition cheat protection to the server.
   #-noupnp						Disables automatic port forwarding
   #-steam							Enables Steam Support
   #-lobby <friends> or <private>				Allows friends to join the server or sets it to private if Steam is enabled
   #-ip <ip address>					Sets the IP address for the server to listen on
   #-forcepriority <priority>				Sets the process priority for this task. If this is used the "priority" setting below will be ignored.
   #-disableannouncementbox				Disables the text announcements Announcement Box makes when pulsed from wire.
   #-announcementboxrange <number>				Sets the announcement box text messaging range in pixels, -1 for serverwide announcements.
   #-seed <seed>						Specifies the world seed when using -autocreate
   
   #remove the # in front of commands to enable them.
   
   #Load a world and automatically start the server.
   world=./Worlds/TerrariaMaster1423.wld
   
   #Creates a new world if none is found. World size is specified by: 1(small), 2(medium), and 3(large).
   autocreate=1
   
   #Sets the world seed when using autocreate
   seed=AwesomeSeed
   
   #Sets the name of the world when using autocreate
   worldname=TerrariaMaster1423
   
   #Sets the difficulty of the world when using autocreate 0(classic), 1(expert), 2(master), 3(journey)
   difficulty=2
   
   #Sets the max number of players allowed on a server.  Value must be between 1 and 255
   maxplayers=8
   
   #Set the port number
   port=7777
   
   #Set the server password
   password=1423
   
   #Set the message of the day
   motd=Please don�t cut the purple trees!
   
   #Sets the folder where world files will be stored
   worldpath=./Worlds/
   
   #Sets the number of rolling world backups to keep
   worldrollbackstokeep=2
   
   #The location of the banlist. Defaults to "banlist.txt" in the working directory.
   #banlist=banlist.txt
   
   #Adds addition cheat protection.
   #secure=1
   
   #Sets the server language from its language code. 
   #English = en-US, German = de-DE, Italian = it-IT, French = fr-FR, Spanish = es-ES, Russian = ru-RU, Chinese = zh-Hans, Portuguese = pt-BR, Polish = pl-PL,
   language=zh-Hans
   
   #Automatically forward ports with uPNP
   #upnp=1
   
   #Reduces enemy skipping but increases bandwidth usage. The lower the number the less skipping will happen, but more data is sent. 0 is off.
   #npcstream=60
   
   #Default system priority 0:Realtime, 1:High, 2:AboveNormal, 3:Normal, 4:BelowNormal, 5:Idle
   priority=1
   
   #Reduces maximum liquids moving at the same time. If enabled may reduce lags but liquids may take longer to settle.
   #slowliquids=1
   
   #Journey mode power permissions for every individual power. 0: Locked for everyone, 1: Can only be changed by host, 2: Can be changed by everyone
   #journeypermission_time_setfrozen=2
   #journeypermission_time_setdawn=2
   #journeypermission_time_setnoon=2
   #journeypermission_time_setdusk=2
   #journeypermission_time_setmidnight=2
   #journeypermission_godmode=2
   #journeypermission_wind_setstrength=2
   #journeypermission_rain_setstrength=2
   #journeypermission_time_setspeed=2
   #journeypermission_rain_setfrozen=2
   #journeypermission_wind_setfrozen=2
   #journeypermission_increaseplacementrange=2
   #journeypermission_setdifficulty=2
   #journeypermission_biomespread_setfrozen=2
   #journeypermission_setspawnrate=2
   ```

   


