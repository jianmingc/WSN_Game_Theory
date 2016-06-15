%Leach协议
%time:          2016.6.8
%Author：       cjm
%Modified：     添加四种簇内通信机制，同时添加EEDBC方法
%               添加check CCH functin组为簇内方案的选取使能端
%Mtime       	no
clc;
clear;%清除內存变量
clear global;

global E0 ETX ERX Efs EDA
global cc CM DM n xm ym

xm=100;%x轴范围
ym=100;%y轴范围

sink.x=0.5*xm;%基站x轴
sink.y=0.5*ym;%基站y轴

n=200;%节点总数

p=0.05;%簇头概率

E0=0.02;%初始能量
ETX=50*0.000000000001;%传输能量，每bit，10e-12
ERX=50*0.000000000001;%接收能量，每bit
Efs=10*0.000000000001;%耗散能量，每bit
EDA=5 *0.000000000001;%融合能耗，每bit

cc=0.6;%融合率

rmax=2000;%总轮数
min_alive_rate=0.1;
min_alive_node=min_alive_rate*n;
CM=32;%控制信息大小
DM=4000;%数据信息大小

LEACH_FLAG=1;
EEDBC_FLAG=0;

%% 为每个节点随机分配坐标，并设置初始能量为E0，节点类型为普通，并绘制基站
for i=1:1:n
    S(i).xd=rand(1,1)*xm;
    S(i).yd=rand(1,1)*ym;
    S(i).G=0;%每一周期結束此变量为0
    S(i).E=E0;%设置初始能量为E0
    S(i).type='N';%节点类型为普通
    S(i).ECflag=0;
    S(i).distance=0;......
end

S(n+1).xd=sink.x;
S(n+1).yd=sink.y;
   figure(1);
%% 开始每轮循环
r=0;
%CCH_D_Flag=0;
%for CCH_D_Flag=0:1:1
%     figure(CCH_D_Flag+1);
 
    for num=1:1:5
%    for CCH_E_Flag=0:1:1
    for i=1:1:n
    S(i).G=0;%每一周期結束此变量为0
    S(i).E=E0;%设置初始能量为E0
    S(i).type='N';%节点类型为普通
    S(i).distance=0;
    end
    flag_first_dead=0;%第一个死亡节点的标识变量
while (1)
  r=r+1;%显示轮数
  %% 变量初始化
    % 如果轮数正好是一個周期的整数倍，则设置S(i).G为0
    if(mod(r,round(1/p))==0)
       for i=1:1:n
           S(i).G=0;
       end
    end
    cluster=0;%初始簇头数为0
    dead=0;%初始死亡节点数为0

    %% 记录死亡节点
     for i=1:1:n
        S(i).ECflag=0;
         % 初始化簇头节点的消息
        G.nodeN=0;%每个CH的非簇头节点号
        G.distance=0;%该非簇头节点与簇头节点的相对距离
        G.resE=0;%该非簇头节点的剩余能量
         % 将能量小于等于0的节点绘制成紅色，并将死亡节点数增加1
         if(S(i).E<=0)
            dead=dead+1;
            if(dead==1)
                if(flag_first_dead==0)
                    first_dead=r %第一个节点的死亡轮数
                    flag_first_dead=1;
                end
            end
         else
             S(i).type='N';
         end      
     end
     Dead(r+1)=dead; %每轮记录当前的死亡节点数
     %% 按概率选取簇头，选出簇头后标识簇头，将簇头标识（位置，距离，ID）都记录下来
       for i=1:1:n
         Count(i)=0;
         if(S(i).E>0)
           if(S(i).G<=0)
            temp_rand=rand;%取一个随机数
            if LEACH_FLAG==1
            %disp('LEACH');
            if(temp_rand<=((p/(1-p*mod(r,round(1/p))))*(S(i).E/E0)))%如果随机数小于等于
            S(i).type='C';%此节点为此轮簇头
            S(i).G=round(1/p)-1;%S(i).G设置为大于0，此周期不能再被选择为簇头
            cluster=cluster+1;%簇头数加1
            C(cluster).xd=S(i).xd;
            C(cluster).yd=S(i).yd;%将此节点标识为簇头

            distance=sqrt((S(i).xd-(S(n+1).xd))^2+(S(i).yd-(S(n+1).yd))^2);%簇头到基站的距离
            S(i).distance=distance;
            C(cluster).distance=distance;%标识为此簇头的距离
            C(cluster).id=i; %此簇头的节点id
            C(cluster).group=G;%簇头中的节点
            C(cluster).CCH_E=G;%簇中的最大能量节点
            C(cluster).CCH_D=G;%簇中的最远距离节点
            packet_To_BS(cluster)=1;%发送到基站的数据包数为1，每个簇头到基站都有一个数据包
            end
            elseif EEDBC_FLAG==1
                max_distance=0;
                min_distance=0;
                for j=1:1:n
                distance=sqrt((S(j).xd-(S(n+1).xd))^2+(S(j).yd-(S(n+1).yd))^2);%簇头到基站的距离
                S(j).distance=distance;
                if distance>max_distance
                    max_distance=distance;
                else
                    min_distance=distance;
                end
                S(j).distance=distance;               
                end
            if(temp_rand<=(p*((S(i).distance-min_distance)/(max_distance-min_distance))*(S(i).E/E0)))%如果随机数小于等于
            S(i).type='C';%此节点为此轮簇头
            S(i).G=round(1/p)-1;%S(i).G设置为大于0，此周期不能再被选择为簇头
            cluster=cluster+1;%簇头数加1
            C(cluster).xd=S(i).xd;
            C(cluster).yd=S(i).yd;%将此节点标识为簇头
            C(cluster).distance=S(i).distance;%标识为此簇头的距离
            C(cluster).id=i; %此簇头的节点id
            C(cluster).group=G;%簇头中的节点
            C(cluster).CCH_E=G;%簇中的最大能量节点
            C(cluster).CCH_D=G;%簇中的最远距离节点
            packet_To_BS(cluster)=1;%发送到基站的数据包数为1，每个簇头到基站都有一个数据包
            end
            end
            end
           end
         end
        CH_Num(r+1)=cluster; %每轮的簇头数
        if(cluster>0)
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
          % disp(['point ',num2str(i),' join ',num2str(min_dis_cluster),' cluster(',num2str(cluster),')']);
         packet_To_BS(min_dis_cluster)=packet_To_BS(min_dis_cluster)+1;
         %节点加入簇的同时，将距离与剩余能量都传输给簇头节点
         Count([min_dis_cluster])=Count([min_dis_cluster])+1;
         C(min_dis_cluster).group.nodeN(Count(min_dis_cluster))=i;
         S(i).distance=min_dis;
         C(min_dis_cluster).group.distance(Count(min_dis_cluster))=min_dis;
         C(min_dis_cluster).group.resE(Count(min_dis_cluster))=S(i).E;
         sum(Count);
         end
        end
        for i=1:1:cluster
            %各簇选择最大能量，和最大距离的节点
            pID_MaxE=find(C(i).group.resE==max(C(i).group.resE));
            if(length(pID_MaxE)>1)
                ID_MinD=pID_MaxE(1);
                for j=2:1:length(pID_MaxE)
                    temp=pID_MaxE(j);
                    if(C(i).group.distance(temp)<C(i).group.distance(ID_MinD))
                        ID_MinD=temp;
                    end
                end
                ID_MaxE=ID_MinD;
            else
            ID_MaxE=pID_MaxE;
            end
            ID_MaxD=find(C(i).group.distance==max(C(i).group.distance));
            %disp(['ID_MaxE = ',num2str(ID_MaxE)]);
            C(i).CCH_E.nodeN=C(i).group.nodeN(ID_MaxE);
            C(i).CCH_D.nodeN=C(i).group.nodeN(ID_MaxD);
            Er_Join(i)=ERX*CM*(packet_To_BS(i)-1);%簇头收到此簇内各个节点加入信息的能耗
         end
        %此节点接收各个簇头的控制信息消耗的能量，n个簇头，n条控制消息
         %此节点加入的簇的簇头时隙控制信息的总接收能耗
%          if (num==5)
         [CCH_E_Flag CCH_D_Flag]=Check_CCH_function(C,S,Er_Join,cluster,num);
         Total_E(r)=sum([S.E]);
%          if r>1
%              disp([num2str(r-1),' round cost ',num2str(Total_E(r-1)-Total_E(r))]);
%          end
%          end
         CHEt1=ETX*CM+Efs*CM*(sqrt(xm*ym))*(sqrt(xm*ym));%簇头单次广播成簇信息的能耗，此处可以考虑第二次广播为小范围广播，带参数
         %% 不同的簇头选取与数据传输方式

         %% 能量簇头与距离簇头均使能
            %将节点类型标记为距离簇头--D与能量簇头--E
             for i=1:1:cluster
               if (CCH_E_Flag==1 && CCH_D_Flag==1)
                 ID_D=C(i).CCH_D.nodeN;
                 ID_E=C(i).CCH_E.nodeN;
                 ID_CH=C(i).id;
                 CH_NOT_Aggre_Flag=0;
                 if (C(i).group.nodeN~=0)%si
                    MemberN=length(C(i).group.nodeN)+1;
                 else
                    MemberN=1;
                 end
                 if (MemberN>1 && ID_E~=ID_D)
                    S(ID_D).type='D';
                    S(ID_E).type='E';
                    CH_NOT_Aggre_Flag=1;
                    CH1=ID_E;
                    CH2=ID_D;
                    Count_D=1;
                 elseif (MemberN>1 && ID_E==ID_D)
                 	if (S(ID_CH).E-2*CHEt1-Er_Join(i)>S(ID_D).E)
                         CH1=ID_CH;
                         CH2=ID_CH;
                         Count_D=0;
                    else
                         S(ID_D).type='D';
                         CH1=ID_E;
                         CH2=ID_CH;
                         Count_D=1;
                    end
                     %disp(['equal! (',num2str(MemberN),')']);
                 else
                     MemberN=1;
                     Count_D=0;
                 end
                  
                  %非簇头节点根据距离重新加入簇
                 for l=1:1:MemberN-1    %簇头类型不用判定
                    if l==1
                       j=ID_CH;
                    else
                       j=C(i).group.nodeN([l]);
                    end
                    if S(j).type=='N'
                        dtoCH1=sqrt((S(j).xd-(S(CH1).xd))^2+(S(j).yd-(S(CH1).yd))^2);
                        dtoCH2=sqrt((S(j).xd-(S(CH2).xd))^2+(S(j).yd-(S(CH2).yd))^2);
                        if dtoCH1>dtoCH2
                        S(j).distance=dtoCH2;
                        Count_D=Count_D+1;
                        else
                        S(j).distance=dtoCH1;
                        end
                    end
                 end

                 %各节点的能量更新
                 for l=1:1:MemberN
                     if l==1
                        j=ID_CH;
                     else
                        j=C(i).group.nodeN([l-1]);
                     end
                     switch S(j).type
                    case 'N'
                       	Er1=ERX*CM*(cluster+1);%接收第一轮广播
                        Er1=Er1+ERX*CM;         %接收第二轮广播
                        %此节点发送加入信息和发送数据信息到簇头的能耗
                        Et1=ETX*(CM+DM)+Efs*(CM+DM)*S(j).distance*S(j).distance;         
                        S(j).E=S(j).E-Er1-Et1;%此轮后的剩余能量
                    case 'C'
                        if (CH_NOT_Aggre_Flag==1)
                        S(j).distance=sqrt((S(j).xd-(S(ID_E).xd))^2+(S(j).yd-(S(ID_E).yd))^2);
                        else
                        CEEr2=ERX*DM*(packet_To_BS(i)-Count_D-1);%收到此簇各个节点数据信息的能耗
                        CEEd1=EDA*DM*cc*(packet_To_BS(i)-Count_D);
                        CEEt2=ETX*DM*cc*(packet_To_BS(i)-Count_D)+Efs*DM*cc*(packet_To_BS(i)-Count_D)*S(j).distance*S(j).distance;%能量簇头将数据融合后发往总簇头的能耗 
                        end
                        CHEr1=Er_Join(i);%簇头收到此簇内各个节点加入信息的能耗
                        CDEt2=ETX*DM+Efs*DM*S(j).distance*S(j).distance;
                        S(j).E=S(j).E-CHEr1-2*CHEt1-CDEt2;
                    case 'E'
                        packet_To_BS(i);%簇头需发送到基站的数据包个数
                        CEEr1=ERX*CM*(cluster+1);%簇头及基站的广播消息
                        CEEr1=CEEr1+ERX*CM;
                        CEEr2=ERX*DM*(packet_To_BS(i)-Count_D-1);%收到此簇各个节点数据信息的能耗
                        CEEd1=EDA*DM*cc*(packet_To_BS(i)-Count_D);
                        CEEt1=ETX*CM+Efs*CM*(S(j).distance)*(S(j).distance);%此节点发送加入消息,use the distance to CH
                        S(j).distance=sqrt((S(j).xd-(S(n+1).xd))^2+(S(j).yd-(S(n+1).yd))^2);%update the distance to BS
                        CEEt2=ETX*DM*cc*(packet_To_BS(i)-Count_D)+Efs*DM*cc*(packet_To_BS(i)-Count_D)*S(j).distance*S(j).distance;%能量簇头将数据融合后发往总簇头的能耗
                        S(j).E=S(j).E-CEEr1-CEEr2-CEEd1-CEEt1-CEEt2;                        
                    case 'D'
                        packet_To_BS(i);%簇头需发送到基站的数据包个数
                        CDr1=ERX*CM*(cluster+1);%簇头及基站的广播消息
                        CDr1=CDr1+ERX*CM;         %1接收控制消息
                        CDr2=ERX*DM*(Count_D-1);       %收到此簇各个节点数据信息的能耗,距离簇头节点
                        CDEt1=ETX*CM+Efs*CM*S(j).distance*S(j).distance;    
                        CDEd1=EDA*DM*cc*Count_D;
                        S(j).distance=sqrt((S(j).xd-(S(n+1).xd))^2+(S(j).yd-(S(n+1).yd))^2);
                        CDEt2=ETX*DM*cc*Count_D+Efs*DM*cc*Count_D*S(j).distance*S(j).distance;%能量簇头将数据融合后发往总簇头的能耗
                        S(j).E=S(j).E-CDr1-CDr2-CDEd1-CDEt1-CDEt2;
                     end
                 S(j).ECflag=1;    
                 end
                 C(i).group=G;
%              end
        
         elseif (CCH_E_Flag==1)
        %% 仅仅能量簇头
             %将节点类型标记为能量簇头--E
%              for i=1:1:cluster
                 ID_E=C(i).CCH_E.nodeN;
                 CH_NOT_Aggre_Flag=1;
                 if (C(i).group.nodeN~=0)%si
                    MemberN=length(C(i).group.nodeN)+1;
                 else
                    MemberN=1;
                 end
                 if ID_E>0
                     if S(ID_E).E>(S(C(i).id).E-2*CHEt1-Er_Join(i))
                     S(ID_E).type='E';
                     else
                         CH_NOT_Aggre_Flag=0;
                     end
                 else
                     MemberN=1;
                 end
                 for l=1:1:MemberN
                     if l==1
                        j=C(i).id;
                     else
                        j=C(i).group.nodeN([l-1]);
                     end
                     switch S(j).type
                    case 'N'
                        if CH_NOT_Aggre_Flag==1
                        S(j).distance=sqrt((S(j).xd-(S(ID_E).xd))^2+(S(j).yd-(S(ID_E).yd))^2);
                        end
                        Er1=ERX*CM*(cluster+1);
                        Er1=Er1+ERX*CM;
                        %此节点发送加入信息和发送数据信息到簇头的能耗
                        Et1=ETX*(CM+DM)+Efs*(CM+DM)*S(j).distance*S(j).distance;         
                        S(j).E=S(j).E-Er1-Et1;%此轮后的剩余能量
                    case 'C'
                        CEEr1=Er_Join(i);%收到此簇各个节点加入信息的能耗
                        CEEt1=2*CHEt1;
                        if (MemberN>1 && CH_NOT_Aggre_Flag==1)
                        S(j).distance=sqrt((S(j).xd-(S(ID_E).xd))^2+(S(j).yd-(S(ID_E).yd))^2);
                        CEEt2=ETX*DM+Efs*DM*S(j).distance*S(j).distance;
                        S(j).E=S(j).E-CEEr1-CEEt1-CEEt2; 
                        elseif (MemberN==1)
                        CEEt2=ETX*DM+Efs*DM*S(j).distance*S(j).distance;
                        S(j).E=S(j).E-CEEr1-CEEt1-CEEt2;
                        else
                        CEEr2=ERX*DM*(packet_To_BS(i)-1);
                        CEEd1=EDA*DM*cc*packet_To_BS(i);
                        CEEt2=ETX*DM*cc*packet_To_BS(i)+Efs*DM*cc*packet_To_BS(i)*S(j).distance*S(j).distance;
                        S(j).E=S(j).E-CEEr1-CEEr2-CEEt1-CEEt2-CEEd1;    
                        end
                    case 'E'
                        packet_To_BS(i);%簇头需发送到基站的数据包个数
                        CEEr1=ERX*CM*(cluster+1);%簇头及基站的广播消息
                        CEEr1=CEEr1+ERX*CM;
                        CEEr2=ERX*DM*(packet_To_BS(i)-1);%收到此簇各个节点数据信息的能耗
                        CEEd1=EDA*DM*cc*packet_To_BS(i);
                        CEEt1=ETX*CM+Efs*CM*(S(j).distance)*(S(j).distance);%此节点发送加入消息
                        S(j).distance=sqrt((S(j).xd-(S(n+1).xd))^2+(S(j).yd-(S(n+1).yd))^2);
                        CEEt2=ETX*DM*cc*packet_To_BS(i)+Efs*DM*cc*packet_To_BS(i)*S(j).distance*S(j).distance;%能量簇头将数据融合后发往总簇头的能耗
                        S(j).E=S(j).E-CEEr1-CEEr2-CEEd1-CEEt1-CEEt2;
                     end
                    S(j).ECflag=1;
                 end
                C(i).group=G;
%              end
         elseif (CCH_D_Flag==1)
        %% 仅仅距离簇头
             %将节点类型标记为距离簇头--D
%              for i=1:1:cluster
                 ID_D=C(i).CCH_D.nodeN;
                 if (C(i).group.nodeN~=0)%si
                    MemberN=length(C(i).group.nodeN)+1;
                 else
                    MemberN=1;
                 end
                 if ID_D>0
                     S(ID_D).type='D';
                 else
                     MemberN=1;
                 end
                 Count_D=1;
                 %非簇头节点根据距离重新加入簇
                 for l=1:1:MemberN
                     if l==1
                        j=C(i).id;
                     else
                        j=C(i).group.nodeN([l-1]);
                     end
                    if S(j).type=='N'
                        dtoCH=sqrt((S(j).xd-(S(C(i).id).xd))^2+(S(j).yd-(S(C(i).id).yd))^2);
                        dtoCH_D=sqrt((S(j).xd-(S(ID_D).xd))^2+(S(j).yd-(S(ID_D).yd))^2);
                        if dtoCH>dtoCH_D
                        S(j).distance=dtoCH_D;
                        Count_D=Count_D+1;
                        else
                        S(j).distance=dtoCH;
                        end
                    end
                 end
                 %各节点的能量更新
                 for l=1:1:MemberN
                     if l==1
                        j=C(i).id;
                     else
                        j=C(i).group.nodeN([l-1]);
                     end
                     switch S(j).type
                    case 'N'
                       	Er1=ERX*CM*(cluster+1);%第一轮广播
                        Er1=Er1+ERX*CM;         %第二轮广播
                        %此节点发送加入信息和发送数据信息到簇头的能耗
                        Et1=ETX*(CM+DM)+Efs*(CM+DM)*S(j).distance*S(j).distance;         
                        S(j).E=S(j).E-Er1-Et1;%此轮后的剩余能量
                    case 'C'
                        CDr1=Er_Join(i);%收到此簇各个节点加入信息的能耗
                        CDr2=ERX*DM*cc*(packet_To_BS(i)-Count_D-1);%收到待聚合的数据
                        CDEd1=EDA*DM*cc*(packet_To_BS(i)-Count_D);
                        CDEt1=2*CHEt1;%此簇头广播成簇信息的能耗，此处可以考虑第二次广播为小范围广播
                        CDEt2=ETX*DM*cc*(packet_To_BS(i)-Count_D)+Efs*DM*cc*(packet_To_BS(i)-Count_D)*S(j).distance*S(j).distance;
                        S(j).E=S(j).E-CDr1-CDr2-CDEd1-CDEt1-CDEt2;
                    case 'D'
                        packet_To_BS(i);%簇头需发送到基站的数据包个数
                        CDr1=ERX*CM*(cluster+1);%簇头及基站的广播消息
                        CDr1=CDr1+ERX*CM;         %1接收控制消息
                        CDr2=ERX*DM*(Count_D-1);       %收到此簇各个节点数据信息的能耗,距离簇头节点
                        CDEt1=ETX*CM+Efs*CM*S(j).distance*S(j).distance;    
                        CDEd1=EDA*DM*cc*Count_D;
                        S(j).distance=sqrt((S(j).xd-(S(n+1).xd))^2+(S(j).yd-(S(n+1).yd))^2);
                        CDEt2=ETX*DM*cc*Count_D+Efs*DM*cc*Count_D*S(j).distance*S(j).distance;%能量簇头将数据融合后发往总簇头的能耗
                        S(j).E=S(j).E-CDr1-CDr2-CDEd1-CDEt1-CDEt2;
                     end
                     S(j).ECflag=1;
                 end
                 C(i).group=G;
%              end
         else
           %% LEACH协议运行
              SN_Sum=0;%debug use
%               for i=1:1:cluster
                 if (C(i).group.nodeN~=0)%si
                    MemberN=length(C(i).group.nodeN)+1;
                 else
                    MemberN=1;
                 end
                 SN_Sum=SN_Sum+MemberN;%debug use
                 for l=1:1:MemberN
                     if l==1
                        j=C(i).id;
                     else
                        j=C(i).group.nodeN([l-1]);
                     end
                     switch S(j).type
                        %普通节点的能量更新
                        case 'N'
                        Er1=ERX*CM*(cluster+1);
                        %此节点发送加入信息和发送数据信息到簇头的能耗
                        Et1=ETX*(CM+DM)+Efs*(CM+DM)*S(j).distance*S(j).distance;         
                        S(j).E=S(j).E-Er1-Et1;%此轮后的剩余能量
                        %各个簇头的能量更新，此轮后簇头的剩余能量
                        case 'C'
                        CEEr1=Er_Join(i);%收到此簇各个节点加入信息的能耗
                        CEEt1=CHEt1;%此簇头广播成簇信息的能耗
                        CEEr2=ERX*DM*(packet_To_BS(i)-1);%收到此簇各个节点数据信息的能耗
                        CEEd1=EDA*DM*cc*packet_To_BS(i);
                        CEEt2=ETX*DM*cc*packet_To_BS(i)+Efs*DM*cc*packet_To_BS(i)*S(j).distance*S(j).distance;%簇头将数据融合后发往基站的能耗
                        S(j).E=S(j).E-CEEr1-CEEr2-CEEt1-CEEt2-CEEd1; 
                     end
                     S(j).ECflag=1;
                 end
                 C(i).group=G;
              end

         end
        else 
             for i=1:1:n
                if(S(i).type=='N'&&S(i).E>0)%对每个能量大于0且非簇头节点
                    Er1=ERX*CM*(cluster+1);
                    %此节点发送加入信息和发送数据信息到簇头的能耗                   
                    Et1=ETX*(CM+DM)+Efs*(CM+DM)*S(i).distance*S(i).distance;                       
                    S(i).E=S(i).E-Er1-Et1;%此轮后的剩余能量
                    S(i).ECflag=1;
                end
             end
        end
%          for i=1:1:n
%              if((S(i).ECflag==0)&&(S(i).E>0))
%                  disp(['node ',num2str(i),' no count ',num2str(r),' round']);
%              end
%          end
%% record
%     for i=1:1:n
%     R(r+1,i)=S(i).E;  %每轮每节点的剩余能量
%     end

     if (dead>95)
        disp(['after ' num2str(r) ' rounds, leave ',num2str(n-dead), ' points!']);
        break;
     end
    x(r)=r;
    y1(r)=n-Dead(r);
%     y2(r)=S(50).E;
%     y3(r)=S(40).E;
%     y4(r)=S(30).E;
%     y5(r)=S(20).E;
%     y6(r)=S(10).E;
%     if(y2(r)==0&&y3(r)==0&&y4(r)==0&&y5(r)==0&&y6(r)==0)    break;
%     end
    if r==rmax
        break;
    end
end
A = [0 0 1; 0 1 0; 0 1 1; 1 0 0; 1 0 1];

if num~=5
%% 绘图
% if (EEDBC_FLAG==0 && LEACH_FLAG==1 && CCH_E_Flag==0)
if (CCH_D_Flag==0 && CCH_E_Flag==0)
    plot(x,y1,'Color',A(1,:));hold on;
    r=0;
% elseif (EEDBC_FLAG==0 && LEACH_FLAG==1 && CCH_E_Flag==1)
elseif (CCH_D_Flag==0 && CCH_E_Flag==1)
    plot(x,y1,'Color',A(2,:));hold on;
    r=0;
% elseif (EEDBC_FLAG==1 && LEACH_FLAG==0 && CCH_E_Flag==0)
elseif (CCH_D_Flag==1 && CCH_E_Flag==0)
    plot(x,y1,'Color',A(3,:));hold on;
    r=0;
% elseif (EEDBC_FLAG==1 && LEACH_FLAG==0 && CCH_E_Flag==1)
elseif (CCH_D_Flag==1 && CCH_E_Flag==1)
    plot(x,y1,'Color',A(4,:));hold on;
    r=0;
end
else
    plot(x,y1,'Color',A(5,:));hold on;
end
% plot(x,y2,'m-',x,y3,'b-',x,y4,'k-',x,y5,'r-',x,y6,'y-');
x=0;
y1=0;
%     LEACH_FLAG=0;
%     EEDBC_FLAG=1;
   end
% legend('LEACH','EEBC');hold off;
% legend('Global Method','Partial Method');hold off;
%end
%     legend('LEACH','CCH_E Enabled','EEBC','EEBC_E Enabled');hold off;
%     LEACH_FLAG=1;
%     EEDBC_FLANG=0;
% end
legend('LEACH','CCH_E Enabled','CCH_D Enabled','CCH_E and CCH_D Enabled','Game Theory Enabled');hold off;
xlabel('Round');
ylabel('residential energy');
% ylabel('number of nodes alive');