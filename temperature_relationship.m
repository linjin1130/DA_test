% author:linjin
% data:2017/5/19
% version:1.0
% filename:temperature_relationship.m
% describe:����DAоƬ�¶��������������ѹ�ı仯��ϵ
% ���Է�������ͬһDA���4��ͨ��У׼��1.28V���ֵ
% ����ѭ������ȡ�¶ȣ���ȡ��ѹ����ͼ
%%
clc;
clear all;
%% ϵͳУ��Ŀ��ֵ
dac_ip='10.0.2.2';
dmm1_ip='10.0.254.3';
dmm2_ip='10.0.254.4';
dmm3_ip='10.0.254.5';
dmm4_ip='10.0.254.6';

dac_ch=1;
gain_code1 = 398;
gain_code2 = 398;
gain_code3 = 398;
gain_code4 = 398;
offset_code1=-177;
offset_code2=-177;
offset_code3=-177;
offset_code4=-177;
%% ϵͳ����У��
GainCode   =zeros(1,4);
GainVoltage =zeros(1,4);
OffsetCode =zeros(1,4);
OffsetVoltage=zeros(1,4);
[GainCode,GainVoltage,OffsetCode,OffsetVoltage]=GainOffsetCorrect(dmm1_ip,dmm2_ip,dmm3_ip,dmm4_ip,dac_ip,80);
%%
disp(GainCode);
disp(GainVoltage);
disp(OffsetCode);
disp(OffsetVoltage);

%% DAC����״̬����
dac = USTCDAC(dac_ip,80);
dac.Open();
display('DAC Init...');
dac.PowerOnDAC(1,0);
dac.PowerOnDAC(2,0);
dac.StartStop(240);
dac.SetGain(1,GainCode(1));
dac.SetGain(2,GainCode(2));
dac.SetGain(3,GainCode(3));
dac.SetGain(4,GainCode(4));
dac.SetDefaultVolt(1, 65535);
dac.SetDefaultVolt(2, 65535);
dac.SetDefaultVolt(3, 65535);
dac.SetDefaultVolt(4, 65535);
%% ���ñ�����

dmm1 = DMM34465A(dmm1_ip);
dmm2 = DMM34465A(dmm2_ip);
dmm3 = DMM34465A(dmm3_ip);
dmm4 = DMM34465A(dmm4_ip);
dmm1.Open();
dmm2.Open();
dmm3.Open();
dmm4.Open();

TestCounter=1;
%% ������ʼ��
TestVolCounter = 1;

store_count = 100000;
database1 = zeros(1,store_count);
database2 = zeros(1,store_count);
database3 = zeros(1,store_count);
database4 = zeros(1,store_count);
temp1arr  = zeros(1,store_count);
temp2arr  = zeros(1,store_count);

yyy = (database1:database2:database3:database4)';
%����ʱ������
t0 = datenum(datestr(now,0));
time_arr = repmat(t0,store_count, 1)
disp(time_arr(1));

test_step = 1
while(1)
    % ѭ����ʾ��Ϣ���
    display(['��ǰ�ļ����Դ���',num2str(TestVolCounter)]);
    % ���ñ����ݲɼ�
    dmm1_value=dmm1.measure_count(test_step);
    dmm2_value=dmm2.measure_count(test_step);
    dmm3_value=dmm3.measure_count(test_step);
    dmm4_value=dmm4.measure_count(test_step);
    temp1 = dac.GetDA1_temp();
    temp2 = dac.GetDA2_temp();
    qq = TestVolCounter*test_step-test_step+1:TestVolCounter*test_step;
    database1(TestVolCounter*test_step-test_step+1:TestVolCounter*test_step) = dmm1_value(:);
    database2(TestVolCounter*test_step-test_step+1:TestVolCounter*test_step) = dmm2_value(:);
    database3(TestVolCounter*test_step-test_step+1:TestVolCounter*test_step) = dmm3_value(:);
    database4(TestVolCounter*test_step-test_step+1:TestVolCounter*test_step) = dmm4_value(:);
    temp1arr(TestVolCounter*test_step-test_step+1:TestVolCounter*test_step) = temp1;
    temp2arr(TestVolCounter*test_step-test_step+1:TestVolCounter*test_step) = temp2;
    delta_ab = dmm2_value - dmm1_value + 0.64;
    delta_ac = dmm3_value - dmm1_value + 0.64;
    delta_ad = dmm4_value - dmm3_value + 0.64;
    %����ʱ����Ϣ
    time_now = datestr(now,0);
    x_pick = datenum(time_now);
    x=x_pick;
    disp(time_now)
    time_arr(TestVolCounter*test_step-test_step+1:TestVolCounter*test_step,:) = x_pick;
    TestCounter=TestCounter+1;
    
    if(TestVolCounter == store_count/test_step)
        %% ������¼�ļ�
        filename = strcat(pwd,strcat(strcat('\data\',['оƬ�¶����ѹ��ϵ',num2str(TestCounter),'_',datestr(now,30)]),'.mat'));
        save('filename.mat');
        movefile('fileName.mat',filename);    
        TestVolCounter = 1;
    end
    TestVolCounter = TestVolCounter+1;
end
%%
dmm1.Close;
dmm2.Close;
dmm3.Close;
dmm4.Close;
dac.Close;

%%
aa = database1(1:1:TestCounter);
bb = database2(1:1:TestCounter);
%%
figure;
subplot(3,2,3);
plot(time_arr(1:1:TestVolCounter-1), database1(1:1:TestVolCounter-1), 'r.', 'MarkerSize', 6);
title('ͨ��1��ѹ');
ylabel('��ѹ(V)');
hold on;
datetick('x', 0);
subplot(3,2,5);
plot(time_arr(1:1:TestVolCounter-1), database2(1:1:TestVolCounter-1), 'g.', 'MarkerSize', 6);
title('ͨ��2��ѹ');
ylabel('��ѹ(V)');
xlabel('����ʱ��');
hold on;
datetick('x', 0)
subplot(3,2,4);
plot(time_arr(1:1:TestVolCounter-1), database3(1:1:TestVolCounter-1), 'b.', 'MarkerSize', 6);
title('ͨ��3��ѹ');
hold on;
datetick('x', 0);
subplot(3,2,6);
plot(time_arr(1:1:TestVolCounter-1), database4(1:1:TestVolCounter-1), 'k.', 'MarkerSize', 6);
title('ͨ��4��ѹ');
xlabel('����ʱ��');
hold on;
datetick('x', 0)
%       plot(x_pick, delta_ab, 'r+', 'MarkerSize', 6);
%      hold on;
%       plot(x_pick, delta_ac, 'b*', 'MarkerSize', 6);
%      hold on;
%       plot(x_pick, delta_ad, 'k+', 'MarkerSize', 6);
%      hold on;
subplot(3,2,1);
plot(time_arr(1:1:TestVolCounter-1), temp1arr(1:1:TestVolCounter-1), 'cs', 'MarkerSize', 6);
title('оƬ1�¶�');
ylabel('�¶ȣ��棩');
hold on;
datetick('x', 0);
subplot(3,2,2);
plot(time_arr(1:1:TestVolCounter-1), temp2arr(1:1:TestVolCounter-1), 'md', 'MarkerSize', 6);
title('оƬ2�¶�');
hold on;
datetick('x', 0);

drawnow;
