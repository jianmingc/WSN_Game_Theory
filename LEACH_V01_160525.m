%LeachЭ��
%time:          2016.5.15
%Author��       cjm
%Modified��     no
%Mtime       	no
clc;
clear;%����ȴ����

xm=100;%x�᷶Χ
ym=100;%y�᷶Χ

sink.x=0.5*xm;%��վx��
sink.y=0.5*ym;%��վy��

n=100;%�ڵ�����

p=0.1;%��ͷ����

E0=0.02;%��ʼ����
ETX=50*0.000000000001;%����������ÿbit��10e-12
ERX=50*0.000000000001;%����������ÿbit
Efs=10*0.000000000001;%��ɢ������ÿbit
EDA=5*0.000000000001;%�ں��ܺģ�ÿbit

cc=0.6;%�ں���

rmax=1000;%������

CM=32;%������Ϣ��С
DM=4000;%������Ϣ��С

figure(1);%��ʾͼƬ
%% Ϊÿ���ڵ�����������꣬�����ó�ʼ����ΪE0���ڵ�����Ϊ��ͨ�������ƻ�վ
for i=1:1:n
    S(i).xd=rand(1,1)*xm;
    S(i).yd=rand(1,1)*ym;
    S(i).G=0;%ÿһ���ڽY���˱���Ϊ0
    S(i).E=E0;%���ó�ʼ������E0
    S(i).type='N';%�ڵ�����Ϊ��ͨ

    plot(S(i).xd,S(i).yd,'o');
    hold on;%����������ͼ��
end

S(n+1).xd=sink.x;
S(n+1).yd=sink.y;
plot(S(n+1).xd,S(n+1).yd,'x');%���ƻ�վ�ڵ�

flag_first_dead=0;%��һ�������ڵ�ı�ʶ����
%% ��ʼÿ��ѭ��
for r=1:1:rmax
  r=r+1;%��ʾ����
  %% ������ʼ��
    % �������������һ�����ڵ���������������S(i).GΪ0
    if(mod(r,round(1/p))==0)
       for i=1:1:n
           S(i).G=0;
       end
    end
    
     hold off;%ÿ��ͼƬ���»���
     cluster=0;%��ʼ��ͷ��Ϊ0
     dead=0;%��ʼ�����ڵ���Ϊ0
     %%%%%%%%%��ͼ
     %figure(1);
    %% ��¼�����ڵ�
     for i=1:1:n
         % ������С�ڵ���0�Ľڵ���Ƴɼtɫ�����������ڵ�������1
         if(S(i).E<=0)
             %%%%%%%%%��ͼ
%            plot(S(i).xd,S(i).yd,'red .');
            dead=dead+1;
            
            if(dead==1)
                if(flag_first_dead==0)
                    first_dead=r %��һ���ڵ����������
                    save ltest, first_dead;
                    flag_first_dead=1;
                end
            end

 %        hold on;
         %���������ڵ㣬�����ڵ�������ʶ
         else
             S(i).type='N';
  %%%%%%%%%��ͼ
  %           plot(S(i).xd,S(i).yd,'o');
             hold on;
         end      
     end
%%%%%%%%%��ͼ
  %   plot(S(n+1).xd,S(n+1).yd,'x');%���ƻ�վ

     Dead(r+1)=dead; %ÿ�ּ�¼��ǰ�������ڵ���
     save ltest, Dead(r+1);%�������ݴ���ltest�ļ�
     
     %% ������ѡȡ��ͷ��ѡ����ͷ���ʶ��ͷ������ͷ��ʶ��λ�ã����룬ID������¼����
     for i=1:1:n
         if(S(i).E>0)
           if(S(i).G<=0)
            temp_rand=rand;%ȡһ�������
            if(temp_rand<=((p/(1-p*mod(r,round(1/p))))*(S(i).E/E0)))%��������С�ڵ���
            %if(temp_rand<=(p/(1-p*mod(r,round(1/p)))))%��������С�ڵ���
            S(i).type='C';%�˽ڵ�Ϊ���ִ�ͷ
            S(i).G=round(1/p)-1;%S(i).G����Ϊ����0�������ڲ����ٱ�ѡ��Ϊ��ͷ
            cluster=cluster+1;%��ͷ����1
            C(cluster).xd=S(i).xd;
            C(cluster).yd=S(i).yd;%���˽ڵ��ʶΪ��ͷ
%%%%%%%%%��ͼ
%            plot(S(i).xd,S(i).yd,'k*');%���ƴ˴�ͷ

            distance=sqrt((S(i).xd-(S(n+1).xd))^2+(S(i).yd-(S(n+1).yd))^2);%��ͷ����վ�ľ���
            C(cluster).distance=distance;%��ʶΪ�˴�ͷ�ľ���
            C(cluster).id=i; %�˴�ͷ�Ľڵ�id

            packet_To_BS(cluster)=1;%���͵���վ�����ݰ���Ϊ1��ÿ����ͷ����վ����һ�����ݰ�
            end
           end
          end
         end

        CH_Num(r+1)=cluster; %ÿ�ֵĴ�ͷ��
        %save ltest,CH_Num(r+1);%����ÿ�ִ�ͷ����ltest
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
         packet_To_BS(min_dis_cluster)=packet_To_BS(min_dis_cluster)+1;                                                                    
        
         %�˽ڵ���ո�����ͷ�Ŀ�����Ϣ���ĵ�������n����ͷ��n��������Ϣ
         %�˽ڵ����ĴصĴ�ͷʱ϶������Ϣ���ܽ����ܺ�
         Er1=ERX*CM*(cluster+1);
         %�˽ڵ㷢�ͼ�����Ϣ�ͷ���������Ϣ����ͷ���ܺ�                   
         Et1=ETX*(CM+DM)+Efs*(CM+DM)*min_dis*min_dis;
                                                      
         S(i).E=S(i).E-Er1-Et1;%���ֺ��ʣ������
         end
     end
     %% ������ͷ���������£����ֺ��ͷ��ʣ������
     for c=1:1:cluster
     packet_To_BS(c);%��ͷ�跢�͵���վ�����ݰ�����
     CEr1=ERX*CM*(packet_To_BS(c)-1);%�յ��˴ظ����ڵ������Ϣ���ܺ�
     CEr2=ERX*DM*(packet_To_BS(c)-1);%�յ��˴ظ����ڵ�������Ϣ���ܺ�
     CEt1=ETX*CM+Efs*CM*(sqrt(xm*ym))*(sqrt(xm*ym));%�˴�ͷ�㲥�ɴ���Ϣ���ܺ�
     CEt2=(ETX+EDA)*DM*cc*packet_To_BS(c)+Efs*DM*cc*packet_To_BS(c)*C(c).distance*C(c).distance;%��ͷ�������ںϺ�����վ���ܺ�
     S(C(c).id).E=S(C(c).id).E-CEr1-CEr2-CEt1-CEt2;
     end
%   
%     for i=1:1:n
%     R(r+1,i)=S(i).E;  %ÿ��ÿ�ڵ��ʣ������
%     % save ltest,R(r+1,i);%��������ݵ�ltest
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