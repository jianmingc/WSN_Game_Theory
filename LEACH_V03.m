%LeachЭ��
%time:          2016.6.8
%Author��       cjm
%Modified��     ������ִ���ͨ�Ż��ƣ�ͬʱ���EEDBC����
%               ���check CCH functin��Ϊ���ڷ�����ѡȡʹ�ܶ�
%Mtime       	no
clc;
clear;%����ȴ����
clear global;

global E0 ETX ERX Efs EDA
global cc CM DM n xm ym

xm=100;%x�᷶Χ
ym=100;%y�᷶Χ

sink.x=0.5*xm;%��վx��
sink.y=0.5*ym;%��վy��

n=200;%�ڵ�����

p=0.05;%��ͷ����

E0=0.02;%��ʼ����
ETX=50*0.000000000001;%����������ÿbit��10e-12
ERX=50*0.000000000001;%����������ÿbit
Efs=10*0.000000000001;%��ɢ������ÿbit
EDA=5 *0.000000000001;%�ں��ܺģ�ÿbit

cc=0.6;%�ں���

rmax=2000;%������
min_alive_rate=0.1;
min_alive_node=min_alive_rate*n;
CM=32;%������Ϣ��С
DM=4000;%������Ϣ��С

LEACH_FLAG=1;
EEDBC_FLAG=0;

%% Ϊÿ���ڵ�����������꣬�����ó�ʼ����ΪE0���ڵ�����Ϊ��ͨ�������ƻ�վ
for i=1:1:n
    S(i).xd=rand(1,1)*xm;
    S(i).yd=rand(1,1)*ym;
    S(i).G=0;%ÿһ���ڽY���˱���Ϊ0
    S(i).E=E0;%���ó�ʼ����ΪE0
    S(i).type='N';%�ڵ�����Ϊ��ͨ
    S(i).ECflag=0;
    S(i).distance=0;......
end

S(n+1).xd=sink.x;
S(n+1).yd=sink.y;
   figure(1);
%% ��ʼÿ��ѭ��
r=0;
%CCH_D_Flag=0;
%for CCH_D_Flag=0:1:1
%     figure(CCH_D_Flag+1);
 
    for num=1:1:5
%    for CCH_E_Flag=0:1:1
    for i=1:1:n
    S(i).G=0;%ÿһ���ڽY���˱���Ϊ0
    S(i).E=E0;%���ó�ʼ����ΪE0
    S(i).type='N';%�ڵ�����Ϊ��ͨ
    S(i).distance=0;
    end
    flag_first_dead=0;%��һ�������ڵ�ı�ʶ����
while (1)
  r=r+1;%��ʾ����
  %% ������ʼ��
    % �������������һ�����ڵ���������������S(i).GΪ0
    if(mod(r,round(1/p))==0)
       for i=1:1:n
           S(i).G=0;
       end
    end
    cluster=0;%��ʼ��ͷ��Ϊ0
    dead=0;%��ʼ�����ڵ���Ϊ0

    %% ��¼�����ڵ�
     for i=1:1:n
        S(i).ECflag=0;
         % ��ʼ����ͷ�ڵ����Ϣ
        G.nodeN=0;%ÿ��CH�ķǴ�ͷ�ڵ��
        G.distance=0;%�÷Ǵ�ͷ�ڵ����ͷ�ڵ����Ծ���
        G.resE=0;%�÷Ǵ�ͷ�ڵ��ʣ������
         % ������С�ڵ���0�Ľڵ���Ƴɼtɫ�����������ڵ�������1
         if(S(i).E<=0)
            dead=dead+1;
            if(dead==1)
                if(flag_first_dead==0)
                    first_dead=r %��һ���ڵ����������
                    flag_first_dead=1;
                end
            end
         else
             S(i).type='N';
         end      
     end
     Dead(r+1)=dead; %ÿ�ּ�¼��ǰ�������ڵ���
     %% ������ѡȡ��ͷ��ѡ����ͷ���ʶ��ͷ������ͷ��ʶ��λ�ã����룬ID������¼����
       for i=1:1:n
         Count(i)=0;
         if(S(i).E>0)
           if(S(i).G<=0)
            temp_rand=rand;%ȡһ�������
            if LEACH_FLAG==1
            %disp('LEACH');
            if(temp_rand<=((p/(1-p*mod(r,round(1/p))))*(S(i).E/E0)))%��������С�ڵ���
            S(i).type='C';%�˽ڵ�Ϊ���ִ�ͷ
            S(i).G=round(1/p)-1;%S(i).G����Ϊ����0�������ڲ����ٱ�ѡ��Ϊ��ͷ
            cluster=cluster+1;%��ͷ����1
            C(cluster).xd=S(i).xd;
            C(cluster).yd=S(i).yd;%���˽ڵ��ʶΪ��ͷ

            distance=sqrt((S(i).xd-(S(n+1).xd))^2+(S(i).yd-(S(n+1).yd))^2);%��ͷ����վ�ľ���
            S(i).distance=distance;
            C(cluster).distance=distance;%��ʶΪ�˴�ͷ�ľ���
            C(cluster).id=i; %�˴�ͷ�Ľڵ�id
            C(cluster).group=G;%��ͷ�еĽڵ�
            C(cluster).CCH_E=G;%���е���������ڵ�
            C(cluster).CCH_D=G;%���е���Զ����ڵ�
            packet_To_BS(cluster)=1;%���͵���վ�����ݰ���Ϊ1��ÿ����ͷ����վ����һ�����ݰ�
            end
            elseif EEDBC_FLAG==1
                max_distance=0;
                min_distance=0;
                for j=1:1:n
                distance=sqrt((S(j).xd-(S(n+1).xd))^2+(S(j).yd-(S(n+1).yd))^2);%��ͷ����վ�ľ���
                S(j).distance=distance;
                if distance>max_distance
                    max_distance=distance;
                else
                    min_distance=distance;
                end
                S(j).distance=distance;               
                end
            if(temp_rand<=(p*((S(i).distance-min_distance)/(max_distance-min_distance))*(S(i).E/E0)))%��������С�ڵ���
            S(i).type='C';%�˽ڵ�Ϊ���ִ�ͷ
            S(i).G=round(1/p)-1;%S(i).G����Ϊ����0�������ڲ����ٱ�ѡ��Ϊ��ͷ
            cluster=cluster+1;%��ͷ����1
            C(cluster).xd=S(i).xd;
            C(cluster).yd=S(i).yd;%���˽ڵ��ʶΪ��ͷ
            C(cluster).distance=S(i).distance;%��ʶΪ�˴�ͷ�ľ���
            C(cluster).id=i; %�˴�ͷ�Ľڵ�id
            C(cluster).group=G;%��ͷ�еĽڵ�
            C(cluster).CCH_E=G;%���е���������ڵ�
            C(cluster).CCH_D=G;%���е���Զ����ڵ�
            packet_To_BS(cluster)=1;%���͵���վ�����ݰ���Ϊ1��ÿ����ͷ����վ����һ�����ݰ�
            end
            end
            end
           end
         end
        CH_Num(r+1)=cluster; %ÿ�ֵĴ�ͷ��
        if(cluster>0)
     %% �ڵ�ѡ���ͷ���Ǵ�ͷ�ڵ����������
        for i=1:1:n
         %ѡ��˽ڵ㵽�ĸ���ͷ�ľ�����С
         if(S(i).type=='N'&&S(i).E>0)%��ÿ����������0�ҷǴ�ͷ�ڵ�
           min_dis=sqrt((S(i).xd-(C(1).xd))^2+(S(i).yd-(C(1).yd))^2);%����˽ڵ㵽��ͷ1�ľ���
           min_dis_cluster=1;
           for c=2:1:cluster
               temp=sqrt((S(i).xd-(C(c).xd))^2+(S(i).yd-(C(c).yd))^2);
               if(temp<min_dis)
                  min_dis=temp;
                  min_dis_cluster=c;
               end
           end
           %�˽ڵ�������Ĵ�ͷ�ڵ����ݰ�����1
          % disp(['point ',num2str(i),' join ',num2str(min_dis_cluster),' cluster(',num2str(cluster),')']);
         packet_To_BS(min_dis_cluster)=packet_To_BS(min_dis_cluster)+1;
         %�ڵ����ص�ͬʱ����������ʣ���������������ͷ�ڵ�
         Count([min_dis_cluster])=Count([min_dis_cluster])+1;
         C(min_dis_cluster).group.nodeN(Count(min_dis_cluster))=i;
         S(i).distance=min_dis;
         C(min_dis_cluster).group.distance(Count(min_dis_cluster))=min_dis;
         C(min_dis_cluster).group.resE(Count(min_dis_cluster))=S(i).E;
         sum(Count);
         end
        end
        for i=1:1:cluster
            %����ѡ�������������������Ľڵ�
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
            Er_Join(i)=ERX*CM*(packet_To_BS(i)-1);%��ͷ�յ��˴��ڸ����ڵ������Ϣ���ܺ�
         end
        %�˽ڵ���ո�����ͷ�Ŀ�����Ϣ���ĵ�������n����ͷ��n��������Ϣ
         %�˽ڵ����ĴصĴ�ͷʱ϶������Ϣ���ܽ����ܺ�
%          if (num==5)
         [CCH_E_Flag CCH_D_Flag]=Check_CCH_function(C,S,Er_Join,cluster,num);
         Total_E(r)=sum([S.E]);
%          if r>1
%              disp([num2str(r-1),' round cost ',num2str(Total_E(r-1)-Total_E(r))]);
%          end
%          end
         CHEt1=ETX*CM+Efs*CM*(sqrt(xm*ym))*(sqrt(xm*ym));%��ͷ���ι㲥�ɴ���Ϣ���ܺģ��˴����Կ��ǵڶ��ι㲥ΪС��Χ�㲥��������
         %% ��ͬ�Ĵ�ͷѡȡ�����ݴ��䷽ʽ

         %% ������ͷ������ͷ��ʹ��
            %���ڵ����ͱ��Ϊ�����ͷ--D��������ͷ--E
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
                  
                  %�Ǵ�ͷ�ڵ���ݾ������¼����
                 for l=1:1:MemberN-1    %��ͷ���Ͳ����ж�
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

                 %���ڵ����������
                 for l=1:1:MemberN
                     if l==1
                        j=ID_CH;
                     else
                        j=C(i).group.nodeN([l-1]);
                     end
                     switch S(j).type
                    case 'N'
                       	Er1=ERX*CM*(cluster+1);%���յ�һ�ֹ㲥
                        Er1=Er1+ERX*CM;         %���յڶ��ֹ㲥
                        %�˽ڵ㷢�ͼ�����Ϣ�ͷ���������Ϣ����ͷ���ܺ�
                        Et1=ETX*(CM+DM)+Efs*(CM+DM)*S(j).distance*S(j).distance;         
                        S(j).E=S(j).E-Er1-Et1;%���ֺ��ʣ������
                    case 'C'
                        if (CH_NOT_Aggre_Flag==1)
                        S(j).distance=sqrt((S(j).xd-(S(ID_E).xd))^2+(S(j).yd-(S(ID_E).yd))^2);
                        else
                        CEEr2=ERX*DM*(packet_To_BS(i)-Count_D-1);%�յ��˴ظ����ڵ�������Ϣ���ܺ�
                        CEEd1=EDA*DM*cc*(packet_To_BS(i)-Count_D);
                        CEEt2=ETX*DM*cc*(packet_To_BS(i)-Count_D)+Efs*DM*cc*(packet_To_BS(i)-Count_D)*S(j).distance*S(j).distance;%������ͷ�������ںϺ����ܴ�ͷ���ܺ� 
                        end
                        CHEr1=Er_Join(i);%��ͷ�յ��˴��ڸ����ڵ������Ϣ���ܺ�
                        CDEt2=ETX*DM+Efs*DM*S(j).distance*S(j).distance;
                        S(j).E=S(j).E-CHEr1-2*CHEt1-CDEt2;
                    case 'E'
                        packet_To_BS(i);%��ͷ�跢�͵���վ�����ݰ�����
                        CEEr1=ERX*CM*(cluster+1);%��ͷ����վ�Ĺ㲥��Ϣ
                        CEEr1=CEEr1+ERX*CM;
                        CEEr2=ERX*DM*(packet_To_BS(i)-Count_D-1);%�յ��˴ظ����ڵ�������Ϣ���ܺ�
                        CEEd1=EDA*DM*cc*(packet_To_BS(i)-Count_D);
                        CEEt1=ETX*CM+Efs*CM*(S(j).distance)*(S(j).distance);%�˽ڵ㷢�ͼ�����Ϣ,use the distance to CH
                        S(j).distance=sqrt((S(j).xd-(S(n+1).xd))^2+(S(j).yd-(S(n+1).yd))^2);%update the distance to BS
                        CEEt2=ETX*DM*cc*(packet_To_BS(i)-Count_D)+Efs*DM*cc*(packet_To_BS(i)-Count_D)*S(j).distance*S(j).distance;%������ͷ�������ںϺ����ܴ�ͷ���ܺ�
                        S(j).E=S(j).E-CEEr1-CEEr2-CEEd1-CEEt1-CEEt2;                        
                    case 'D'
                        packet_To_BS(i);%��ͷ�跢�͵���վ�����ݰ�����
                        CDr1=ERX*CM*(cluster+1);%��ͷ����վ�Ĺ㲥��Ϣ
                        CDr1=CDr1+ERX*CM;         %1���տ�����Ϣ
                        CDr2=ERX*DM*(Count_D-1);       %�յ��˴ظ����ڵ�������Ϣ���ܺ�,�����ͷ�ڵ�
                        CDEt1=ETX*CM+Efs*CM*S(j).distance*S(j).distance;    
                        CDEd1=EDA*DM*cc*Count_D;
                        S(j).distance=sqrt((S(j).xd-(S(n+1).xd))^2+(S(j).yd-(S(n+1).yd))^2);
                        CDEt2=ETX*DM*cc*Count_D+Efs*DM*cc*Count_D*S(j).distance*S(j).distance;%������ͷ�������ںϺ����ܴ�ͷ���ܺ�
                        S(j).E=S(j).E-CDr1-CDr2-CDEd1-CDEt1-CDEt2;
                     end
                 S(j).ECflag=1;    
                 end
                 C(i).group=G;
%              end
        
         elseif (CCH_E_Flag==1)
        %% ����������ͷ
             %���ڵ����ͱ��Ϊ������ͷ--E
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
                        %�˽ڵ㷢�ͼ�����Ϣ�ͷ���������Ϣ����ͷ���ܺ�
                        Et1=ETX*(CM+DM)+Efs*(CM+DM)*S(j).distance*S(j).distance;         
                        S(j).E=S(j).E-Er1-Et1;%���ֺ��ʣ������
                    case 'C'
                        CEEr1=Er_Join(i);%�յ��˴ظ����ڵ������Ϣ���ܺ�
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
                        packet_To_BS(i);%��ͷ�跢�͵���վ�����ݰ�����
                        CEEr1=ERX*CM*(cluster+1);%��ͷ����վ�Ĺ㲥��Ϣ
                        CEEr1=CEEr1+ERX*CM;
                        CEEr2=ERX*DM*(packet_To_BS(i)-1);%�յ��˴ظ����ڵ�������Ϣ���ܺ�
                        CEEd1=EDA*DM*cc*packet_To_BS(i);
                        CEEt1=ETX*CM+Efs*CM*(S(j).distance)*(S(j).distance);%�˽ڵ㷢�ͼ�����Ϣ
                        S(j).distance=sqrt((S(j).xd-(S(n+1).xd))^2+(S(j).yd-(S(n+1).yd))^2);
                        CEEt2=ETX*DM*cc*packet_To_BS(i)+Efs*DM*cc*packet_To_BS(i)*S(j).distance*S(j).distance;%������ͷ�������ںϺ����ܴ�ͷ���ܺ�
                        S(j).E=S(j).E-CEEr1-CEEr2-CEEd1-CEEt1-CEEt2;
                     end
                    S(j).ECflag=1;
                 end
                C(i).group=G;
%              end
         elseif (CCH_D_Flag==1)
        %% ���������ͷ
             %���ڵ����ͱ��Ϊ�����ͷ--D
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
                 %�Ǵ�ͷ�ڵ���ݾ������¼����
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
                 %���ڵ����������
                 for l=1:1:MemberN
                     if l==1
                        j=C(i).id;
                     else
                        j=C(i).group.nodeN([l-1]);
                     end
                     switch S(j).type
                    case 'N'
                       	Er1=ERX*CM*(cluster+1);%��һ�ֹ㲥
                        Er1=Er1+ERX*CM;         %�ڶ��ֹ㲥
                        %�˽ڵ㷢�ͼ�����Ϣ�ͷ���������Ϣ����ͷ���ܺ�
                        Et1=ETX*(CM+DM)+Efs*(CM+DM)*S(j).distance*S(j).distance;         
                        S(j).E=S(j).E-Er1-Et1;%���ֺ��ʣ������
                    case 'C'
                        CDr1=Er_Join(i);%�յ��˴ظ����ڵ������Ϣ���ܺ�
                        CDr2=ERX*DM*cc*(packet_To_BS(i)-Count_D-1);%�յ����ۺϵ�����
                        CDEd1=EDA*DM*cc*(packet_To_BS(i)-Count_D);
                        CDEt1=2*CHEt1;%�˴�ͷ�㲥�ɴ���Ϣ���ܺģ��˴����Կ��ǵڶ��ι㲥ΪС��Χ�㲥
                        CDEt2=ETX*DM*cc*(packet_To_BS(i)-Count_D)+Efs*DM*cc*(packet_To_BS(i)-Count_D)*S(j).distance*S(j).distance;
                        S(j).E=S(j).E-CDr1-CDr2-CDEd1-CDEt1-CDEt2;
                    case 'D'
                        packet_To_BS(i);%��ͷ�跢�͵���վ�����ݰ�����
                        CDr1=ERX*CM*(cluster+1);%��ͷ����վ�Ĺ㲥��Ϣ
                        CDr1=CDr1+ERX*CM;         %1���տ�����Ϣ
                        CDr2=ERX*DM*(Count_D-1);       %�յ��˴ظ����ڵ�������Ϣ���ܺ�,�����ͷ�ڵ�
                        CDEt1=ETX*CM+Efs*CM*S(j).distance*S(j).distance;    
                        CDEd1=EDA*DM*cc*Count_D;
                        S(j).distance=sqrt((S(j).xd-(S(n+1).xd))^2+(S(j).yd-(S(n+1).yd))^2);
                        CDEt2=ETX*DM*cc*Count_D+Efs*DM*cc*Count_D*S(j).distance*S(j).distance;%������ͷ�������ںϺ����ܴ�ͷ���ܺ�
                        S(j).E=S(j).E-CDr1-CDr2-CDEd1-CDEt1-CDEt2;
                     end
                     S(j).ECflag=1;
                 end
                 C(i).group=G;
%              end
         else
           %% LEACHЭ������
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
                        %��ͨ�ڵ����������
                        case 'N'
                        Er1=ERX*CM*(cluster+1);
                        %�˽ڵ㷢�ͼ�����Ϣ�ͷ���������Ϣ����ͷ���ܺ�
                        Et1=ETX*(CM+DM)+Efs*(CM+DM)*S(j).distance*S(j).distance;         
                        S(j).E=S(j).E-Er1-Et1;%���ֺ��ʣ������
                        %������ͷ���������£����ֺ��ͷ��ʣ������
                        case 'C'
                        CEEr1=Er_Join(i);%�յ��˴ظ����ڵ������Ϣ���ܺ�
                        CEEt1=CHEt1;%�˴�ͷ�㲥�ɴ���Ϣ���ܺ�
                        CEEr2=ERX*DM*(packet_To_BS(i)-1);%�յ��˴ظ����ڵ�������Ϣ���ܺ�
                        CEEd1=EDA*DM*cc*packet_To_BS(i);
                        CEEt2=ETX*DM*cc*packet_To_BS(i)+Efs*DM*cc*packet_To_BS(i)*S(j).distance*S(j).distance;%��ͷ�������ںϺ�����վ���ܺ�
                        S(j).E=S(j).E-CEEr1-CEEr2-CEEt1-CEEt2-CEEd1; 
                     end
                     S(j).ECflag=1;
                 end
                 C(i).group=G;
              end

         end
        else 
             for i=1:1:n
                if(S(i).type=='N'&&S(i).E>0)%��ÿ����������0�ҷǴ�ͷ�ڵ�
                    Er1=ERX*CM*(cluster+1);
                    %�˽ڵ㷢�ͼ�����Ϣ�ͷ���������Ϣ����ͷ���ܺ�                   
                    Et1=ETX*(CM+DM)+Efs*(CM+DM)*S(i).distance*S(i).distance;                       
                    S(i).E=S(i).E-Er1-Et1;%���ֺ��ʣ������
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
%     R(r+1,i)=S(i).E;  %ÿ��ÿ�ڵ��ʣ������
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
%% ��ͼ
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