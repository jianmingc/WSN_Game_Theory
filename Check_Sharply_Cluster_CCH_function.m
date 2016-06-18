function [E_Flag D_Flag]=Check_Cluster_CCH_function(CH_ALL, SN_ALL, Er_Join, cluster_num)

global ETX ERX Efs
global cc CM DM n xm ym
global Total_E
cluster=cluster_num;
CHEt1=ETX*CM+Efs*CM*(sqrt(xm*ym))*(sqrt(xm*ym));
Total_E(1)=0;
Total_E(2)=0;
Total_E(3)=0;
Total_E(4)=0;
S1=SN_ALL;
C1=CH_ALL;
S2=SN_ALL;
C2=CH_ALL;
S3=SN_ALL;
C3=CH_ALL;
S4=SN_ALL;
C4=CH_ALL;
%% ������ͷ������ͷ��ʹ��
%���ڵ����ͱ��Ϊ�����ͷ--D��������ͷ--E
	ID_D=C1.CCH_D.nodeN;
	ID_E=C1.CCH_E.nodeN;
	ID_CH=C1.id;
	CH_NOT_Aggre_Flag=0;
	if (C1.group.nodeN~=0)%si
        MemberN=length(C1.group.nodeN)+1;
    else
        MemberN=1;
    end
	if (MemberN>1 && ID_E~=ID_D)
        S1(ID_D).type='D';
        S1(ID_E).type='E';
        CH_NOT_Aggre_Flag=1;
        CH1=ID_E;
        CH2=ID_D;
        Count_D=1;
	elseif (MemberN>1 && ID_E==ID_D)
        if (S1(ID_CH).E-2*CHEt1-Er_Join>S1(ID_D).E)
            CH1=ID_CH;
            CH2=ID_CH;
            Count_D=0;
        else
        S1(ID_D).type='D';
        CH1=ID_E;
        CH2=ID_CH;
        Count_D=1;
        end
	else
        MemberN=1;
        Count_D=0;
    end
    
    %�Ǵ�ͷ�ڵ���ݾ������¼����
    for l=1:1:MemberN-1    %��ͷ���Ͳ����ж�
        if l==1
            j=ID_CH;
        else
            j=C1.group.nodeN([l]);
        end
        if S1(j).type=='N'
            dtoCH1=sqrt((S1(j).xd-(S1(CH1).xd))^2+(S1(j).yd-(S1(CH1).yd))^2);
            dtoCH2=sqrt((S1(j).xd-(S1(CH2).xd))^2+(S1(j).yd-(S1(CH2).yd))^2);
            if dtoCH1>dtoCH2
            S1(j).distance=dtoCH2;
            Count_D=Count_D+1;
            else
                S1(j).distance=dtoCH1;
            end
        end
    end
    
    %���ڵ����������
    for l=1:1:MemberN
        if l==1
            j=ID_CH;
        else
            j=C1.group.nodeN([l-1]);
        end
        switch S1(j).type
            case 'N'
                Er1=ERX*CM;         %���յڶ��ֹ㲥
                %�˽ڵ㷢�ͼ�����Ϣ�ͷ���������Ϣ����ͷ���ܺ�
                Et1=ETX*(CM+DM)+Efs*(CM+DM)*S1(j).distance*S1(j).distance;         
                Total_E(1)=Total_E(1)+Er1+Et1;%���ֺ��ʣ������
            case 'C'
                if (CH_NOT_Aggre_Flag==1)
                    S1(j).distance=sqrt((S1(j).xd-(S1(ID_E).xd))^2+(S1(j).yd-(S1(ID_E).yd))^2);
                else
                    CEEr2=ERX*DM*(MemberN-Count_D-1);%�յ��˴ظ����ڵ�������Ϣ���ܺ�
                    CEEt2=ETX*DM*cc*(MemberN-Count_D)+Efs*DM*cc*(MemberN-Count_D)*S1(j).distance*S1(j).distance;%������ͷ�������ںϺ����ܴ�ͷ���ܺ�   
                    Total_E(1)=Total_E(1)+CEEr2+CEEt2;
                end
                CDEt2=Efs*DM*S1(j).distance*S1(j).distance;
                Total_E(1)=Total_E(1)+CHEt1+CDEt2;
            case 'E'
                CEEr1=ERX*CM;
                CEEr2=ERX*DM*(MemberN-Count_D-1);%�յ��˴ظ����ڵ�������Ϣ���ܺ�
                CEEt1=ETX*CM+Efs*CM*(S1(j).distance)*(S1(j).distance);%�˽ڵ㷢�ͼ�����Ϣ,use the distance to CH
                S1(j).distance=sqrt((S1(j).xd-(S1(n+1).xd))^2+(S1(j).yd-(S1(n+1).yd))^2);%update the distance to BS
                CEEt2=ETX*DM*cc*(MemberN-Count_D)+Efs*DM*cc*(MemberN-Count_D)*S1(j).distance*S1(j).distance;%������ͷ�������ںϺ����ܴ�ͷ���ܺ�
                Total_E(1)=Total_E(1)+CEEr1+CEEr2+CEEt1+CEEt2;                        
            case 'D'
                CDr1=ERX*CM;         %1���տ�����Ϣ
                CDr2=ERX*DM*(Count_D-1);       %�յ��˴ظ����ڵ�������Ϣ���ܺ�,�����ͷ�ڵ�
                CDEt1=ETX*CM+Efs*CM*S1(j).distance*S1(j).distance;    
                S1(j).distance=sqrt((S1(j).xd-(S1(n+1).xd))^2+(S1(j).yd-(S1(n+1).yd))^2);
                CDEt2=ETX*DM*cc*Count_D+Efs*DM*cc*Count_D*S1(j).distance*S1(j).distance;%������ͷ�������ںϺ����ܴ�ͷ���ܺ�
                Total_E(1)=Total_E(1)+CDr1+CDr2+CDEt1+CDEt2;
        end
    end
    %% ����������ͷ(CCH_E_Flag==1)
    %���ڵ����ͱ��Ϊ������ͷ--E
    ID_E=C2.CCH_E.nodeN;
    CH_NOT_Aggre_Flag=1;
    if (C2.group.nodeN~=0)%si
        MemberN=length(C2.group.nodeN)+1;
    else
        MemberN=1;
    end
    if ID_E>0
        if S2(ID_E).E>(S2(C2.id).E-2*CHEt1-Er_Join)
            S2(ID_E).type='E';
        else
            CH_NOT_Aggre_Flag=0;
        end
    else
        MemberN=1;  
    end
    for l=1:1:MemberN
        if l==1
            j=C2.id;
        else
            j=C2.group.nodeN([l-1]);
        end
        switch S2(j).type
            case 'N'
                if CH_NOT_Aggre_Flag==1
                    S2(j).distance=sqrt((S2(j).xd-(S2(ID_E).xd))^2+(S2(j).yd-(S2(ID_E).yd))^2);
                end
                Er1=ERX*CM;
                %�˽ڵ㷢�ͼ�����Ϣ�ͷ���������Ϣ����ͷ���ܺ�
                Et1=ETX*(CM+DM)+Efs*(CM+DM)*S2(j).distance*S2(j).distance;         
                Total_E(2)=Total_E(2)+Er1+Et1;%���ֺ��ʣ������
            case 'C'
                CEEt1=CHEt1;
                if (MemberN>1 && CH_NOT_Aggre_Flag==1)
                    S2(j).distance=sqrt((S2(j).xd-(S2(ID_E).xd))^2+(S2(j).yd-(S2(ID_E).yd))^2);
                    CEEt2=ETX*DM+Efs*DM*S2(j).distance*S2(j).distance;
                    Total_E(2)=Total_E(2)+CEEt1+CEEt2; 
                elseif (MemberN==1)
                    CEEt2=ETX*DM+Efs*DM*S2(j).distance*S2(j).distance;
                    Total_E(2)=Total_E(2)+CEEt1+CEEt2; 
                else
                    CEEr2=ERX*DM*(MemberN-1);
                    CEEt2=ETX*DM*cc*MemberN+Efs*DM*cc*MemberN*S2(j).distance*S2(j).distance;
                    Total_E(2)=Total_E(2)+CEEr2+CEEt1+CEEt2;    
                end
            case 'E'
                CEEr1=ERX*CM;
                CEEr2=ERX*DM*(MemberN-1);%�յ��˴ظ����ڵ�������Ϣ���ܺ�
                CEEt1=ETX*CM+Efs*CM*(S2(j).distance)*(S2(j).distance);%�˽ڵ㷢�ͼ�����Ϣ
                S2(j).distance=sqrt((S2(j).xd-(S2(n+1).xd))^2+(S2(j).yd-(S2(n+1).yd))^2);
                CEEt2=ETX*DM*cc*MemberN+Efs*DM*cc*MemberN*S2(j).distance*S2(j).distance;%������ͷ�������ںϺ����ܴ�ͷ���ܺ�
                Total_E(2)=Total_E(2)+CEEr1+CEEr2+CEEt1+CEEt2;
        end
    end
    %% ���������ͷ(CCH_D_Flag==1)
    %���ڵ����ͱ��Ϊ�����ͷ--D
    ID_D=C3.CCH_D.nodeN; 
    if (C3.group.nodeN~=0)%si 
        MemberN=length(C3.group.nodeN)+1;
    else
        MemberN=1;
    end
    if ID_D>0
        S3(ID_D).type='D';
    else
        MemberN=1;    
    end
    Count_D=1;
    %�Ǵ�ͷ�ڵ���ݾ������¼���� 
    for l=1:1:MemberN 
        if l==1
            j=C3.id; 
        else
            j=C3.group.nodeN([l-1]);
        end
        if S3(j).type=='N'   
            dtoCH=sqrt((S3(j).xd-(S3(C3.id).xd))^2+(S3(j).yd-(S3(C3.id).yd))^2); 
            dtoCH_D=sqrt((S3(j).xd-(S3(ID_D).xd))^2+(S3(j).yd-(S3(ID_D).yd))^2);   
            if dtoCH>dtoCH_D
                S3(j).distance=dtoCH_D;
                Count_D=Count_D+1;
            else
                S3(j).distance=dtoCH;
            end
        end
    end
    %���ڵ����������
    for l=1:1:MemberN
        if l==1
            j=C3.id;
        else
            j=C3.group.nodeN([l-1]);
        end
        switch S3(j).type
            case 'N'      	    
                Er1=ERX*CM;         %�ڶ��ֹ㲥
                %�˽ڵ㷢�ͼ�����Ϣ�ͷ���������Ϣ����ͷ���ܺ�
                Et1=ETX*(CM+DM)+Efs*(CM+DM)*S3(j).distance*S3(j).distance;         
                Total_E(3)=Total_E(3)+Er1+Et1;%���ֺ��ʣ������
            case 'C'
                CDr2=ERX*DM*cc*(MemberN-Count_D-1);%�յ����ۺϵ�����
                CDEt1=CHEt1;%�˴�ͷ�㲥�ɴ���Ϣ���ܺģ��˴����Կ��ǵڶ��ι㲥ΪС��Χ�㲥
                CDEt2=ETX*DM*cc*(MemberN-Count_D)+Efs*DM*cc*(MemberN-Count_D)*S3(j).distance*S3(j).distance;
                Total_E(3)=Total_E(3)+CDr2+CDEt1+CDEt2;
            case 'D'
                CDr1=ERX*CM;         %1���տ�����Ϣ
                CDr2=ERX*DM*(Count_D-1);       %�յ��˴ظ����ڵ�������Ϣ���ܺ�,�����ͷ�ڵ�
                CDEt1=ETX*CM+Efs*CM*S3(j).distance*S3(j).distance;    
                S3(j).distance=sqrt((S3(j).xd-(S3(n+1).xd))^2+(S3(j).yd-(S3(n+1).yd))^2);
                CDEt2=ETX*DM*cc*Count_D+Efs*DM*cc*Count_D*S3(j).distance*S3(j).distance;%������ͷ�������ںϺ����ܴ�ͷ���ܺ�
                Total_E(3)=Total_E(3)+CDr1+CDr2+CDEt1+CDEt2;
        end
    end
    %% LEACHЭ������
    if (C4.group.nodeN~=0)%si
        MemberN=length(C4.group.nodeN)+1;
    else
        MemberN=1;
    end
    for l=1:1:MemberN
        if l==1
            j=C4.id;    
        else
            j=C4.group.nodeN([l-1]);     
        end
        switch S4(j).type
            %��ͨ�ڵ����������
            case 'N'
                %�˽ڵ㷢�ͼ�����Ϣ�ͷ���������Ϣ����ͷ���ܺ�
                Et1=ETX*(CM+DM)+Efs*(CM+DM)*S4(j).distance*S4(j).distance;         
                Total_E(4)=Total_E(4)+Et1;%���ֺ��ʣ������
                %������ͷ���������£����ֺ��ͷ��ʣ������
            case 'C'
                CEEr2=ERX*DM*(MemberN-1);%�յ��˴ظ����ڵ�������Ϣ���ܺ�
                CEEt2=ETX*DM*cc*MemberN+Efs*DM*cc*MemberN*S4(j).distance*S4(j).distance;%��ͷ�������ںϺ�����վ���ܺ�
                Total_E(4)=Total_E(4)+CEEr2+CEEt1+CEEt2; 
        end
    end

    if (Total_E(1)==min(Total_E))
        E_Flag=0;
        D_Flag=0;
    else
        x=shapley(@eigen1,2);
%         x
%         for i=1:2
%             si(i)=x(i)/sum(x);
%         end
        if x(1)>x(2)
            E_Flag=0;
            D_Flag=1;
        else
            E_Flag=1;
            D_Flag=0;
        end
        E_Flag=0;
        D_Flag=1;
    end

%%sharpley main loop
function f=shapley(v,n)
%�����Բ�ģ�ͳ��� 
e=ones(1,n);      %[1 1]
f=e*feval(v,e)/n; %����ĺ�����䷽��[0.5 0.5]
x=ones(1,n);      %��m�ֺ�����ʽ�������Ʊ�ʾ��,[1 1 1]
for m=1:2^n-2     %1:6
    for i=1:n     %3
        x(i)=floor(m/2^(n-i));%[m/(2^(3-i))],[m/4,m/2,m]
        m=m-x(i)*2^(n-i);     %m-[4 2 1]x(i)
    end
    p=feval(v,x);%��m�ֺ�����ʽ�Ļ���
    s=sum(x);
    w1=1/s/nchoosek(n,s);%��Ȩ����[n��ȡS��Ԫ�ص����������]
    w2=w1*s/(n-s);
    f=f+p*w1*x-p*w2*(e-x);
end
%%sharply handler function
function v=eigen1(x)
global Total_E
v=0;
s=sum(x);
Base_E=0;
Base_E=Total_E(4);
if x==[1 0]	v=Total_E(2);    end          %���˻���
if x==[0 1]	v=Total_E(3);	end   %���Һ�������
if s==2     v=Total_E(1);	end                  %���˺�������
v=v-Base_E;
 return ;
