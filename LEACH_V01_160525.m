%Leach协议
%time:          2016.5.15
%Author：       cjm
%Modified：     no
%Mtime       	no
clc;
clear;%清除內存变量

xm=100;%x轴范围
ym=100;%y轴范围

sink.x=0.5*xm;%基站x轴
sink.y=0.5*ym;%基站y轴

n=100;%节点总数

p=0.1;%簇头概率

E0=0.02;%初始能量
ETX=50*0.000000000001;%传输能量，每bit，10e-12
ERX=50*0.000000000001;%接收能量，每bit
Efs=10*0.000000000001;%耗散能量，每bit
EDA=5*0.000000000001;%融合能耗，每bit

cc=0.6;%融合率

rmax=1000;%总轮数

CM=32;%控制信息大小
DM=4000;%数据信息大小

figure(1);%显示图片
%% 为每个节点随机分配坐标，并设置初始能量为E0，节点类型为普通，并绘制基站
for i=1:1:n
    S(i).xd=rand(1,1)*xm;
    S(i).yd=rand(1,1)*ym;
    S(i).G=0;%每一周期結束此变量为0
    S(i).E=E0;%设置初始能能量E0
    S(i).type='N';%节点类型为普通

    plot(S(i).xd,S(i).yd,'o');
    hold on;%保持所画的图像
end

S(n+1).xd=sink.x;
S(n+1).yd=sink.y;
plot(S(n+1).xd,S(n+1).yd,'x');%绘制基站节点

flag_first_dead=0;%第一个死亡节点的标识变量
%% 开始每轮循环
for r=1:1:rmax
  r=r+1;%显示轮数
  %% 变量初始化
    % 如果轮数正好是一個周期的整数倍，则设置S(i).G为0
    if(mod(r,round(1/p))==0)
       for i=1:1:n
           S(i).G=0;
       end
    end
    
     hold off;%每轮图片重新绘制
     cluster=0;%初始簇头数为0
     dead=0;%初始死亡节点数为0
     %%%%%%%%%绘图
     %figure(1);
    %% 记录死亡节点
     for i=1:1:n
         % 将能量小于等于0的节点绘制成紅色，并将死亡节点数增加1
         if(S(i).E<=0)
             %%%%%%%%%绘图
%            plot(S(i).xd,S(i).yd,'red .');
            dead=dead+1;
            
            if(dead==1)
                if(flag_first_dead==0)
                    first_dead=r %第一个节点的死亡轮数
                    save ltest, first_dead;
                    flag_first_dead=1;
                end
            end

 %        hold on;
         %绘制其他节点，其他节点正常标识
         else
             S(i).type='N';
  %%%%%%%%%绘图
  %           plot(S(i).xd,S(i).yd,'o');
             hold on;
         end      
     end
%%%%%%%%%绘图
  %   plot(S(n+1).xd,S(n+1).yd,'x');%绘制基站

     Dead(r+1)=dead; %每轮记录当前的死亡节点数
     save ltest, Dead(r+1);%将此数据存入ltest文件
     
     %% 按概率选取簇头，选出簇头后标识簇头，将簇头标识（位置，距离，ID）都记录下来
     for i=1:1:n
         if(S(i).E>0)
           if(S(i).G<=0)
            temp_rand=rand;%取一个随机数
            if(temp_rand<=((p/(1-p*mod(r,round(1/p))))*(S(i).E/E0)))%如果随机数小于等于
            %if(temp_rand<=(p/(1-p*mod(r,round(1/p)))))%如果随机数小于等于
            S(i).type='C';%此节点为此轮簇头
            S(i).G=round(1/p)-1;%S(i).G设置为大于0，此周期不能再被选择为簇头
            cluster=cluster+1;%簇头数加1
            C(cluster).xd=S(i).xd;
            C(cluster).yd=S(i).yd;%将此节点标识为簇头
%%%%%%%%%绘图
%            plot(S(i).xd,S(i).yd,'k*');%绘制此簇头

            distance=sqrt((S(i).xd-(S(n+1).xd))^2+(S(i).yd-(S(n+1).yd))^2);%簇头到基站的距离
            C(cluster).distance=distance;%标识为此簇头的距离
            C(cluster).id=i; %此簇头的节点id

            packet_To_BS(cluster)=1;%发送到基站的数据包数为1，每个簇头到基站都有一个数据包
            end
           end
          end
         end

        CH_Num(r+1)=cluster; %每轮的簇头数
        %save ltest,CH_Num(r+1);%保存每轮簇头数到ltest
     %% 节点选择簇头及非簇头节点的能量更新
        for i=1:1:n
         %选择此节点到哪个簇头的距离最小
         if(S(i).type=='N'&&S(i).E>0)%对每个能量大于0且非簇头节点
           min_dis=sqrt((S(i).xd-(C(1).xd))^2+(S(i).yd-(C(1).yd))^2);%计算此节点到簇头1的距离
           min_dis_cluster=1;
           for c=2:1:cluster
               temp=sqrt((S(i).xd-(C(c).xd))^2+(S(i).yd-(C(c).yd))^2);
               if(temp<min_dis)
                  min_dis=temp;
                  min_dis_cluster=c;
               end
           end
           %此节点所加入的簇头节点数据包数加1
         packet_To_BS(min_dis_cluster)=packet_To_BS(min_dis_cluster)+1;                                                                    
        
         %此节点接收各个簇头的控制信息消耗的能量，n个簇头，n条控制消息
         %此节点加入的簇的簇头时隙控制信息的总接收能耗
         Er1=ERX*CM*(cluster+1);
         %此节点发送加入信息和发送数据信息到簇头的能耗                   
         Et1=ETX*(CM+DM)+Efs*(CM+DM)*min_dis*min_dis;
                                                      
         S(i).E=S(i).E-Er1-Et1;%此轮后的剩余能量
         end
     end
     %% 各个簇头的能量更新，此轮后簇头的剩余能量
     for c=1:1:cluster
     packet_To_BS(c);%簇头需发送到基站的数据包个数
     CEr1=ERX*CM*(packet_To_BS(c)-1);%收到此簇各个节点加入信息的能耗
     CEr2=ERX*DM*(packet_To_BS(c)-1);%收到此簇各个节点数据信息的能耗
     CEt1=ETX*CM+Efs*CM*(sqrt(xm*ym))*(sqrt(xm*ym));%此簇头广播成簇信息的能耗
     CEt2=(ETX+EDA)*DM*cc*packet_To_BS(c)+Efs*DM*cc*packet_To_BS(c)*C(c).distance*C(c).distance;%簇头将数据融合后发往基站的能耗
     S(C(c).id).E=S(C(c).id).E-CEr1-CEr2-CEt1-CEt2;
     end
%   
%     for i=1:1:n
%     R(r+1,i)=S(i).E;  %每轮每节点的剩余能量
%     % save ltest,R(r+1,i);%保存此数据到ltest
%     end
    hold on;
end
figure(2);
for r=1:1:rmax
x(r)=r;
y(r)=n-Dead(r);
end;
plot(x,y,'-');
xlabel('Round');
ylabel('number of nodes alive');