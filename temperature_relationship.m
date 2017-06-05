% author:linjin
% data:2017/5/19
% version:1.0
% filename:temperature_relationship.m
% describe:测试DA芯片温度与托盘输出最大电压的变化关系
% 测试方法：将同一DA板的4个通道校准到1.28V峰峰值
% 无限循环，读取温度，读取电压，绘图
%%
clc;
clear all;
%% 系统校正目标值
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
%% 系统参数校正
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

%% DAC工作状态设置
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
%% 万用表设置

dmm1 = DMM34465A(dmm1_ip);
dmm2 = DMM34465A(dmm2_ip);
dmm3 = DMM34465A(dmm3_ip);
dmm4 = DMM34465A(dmm4_ip);
dmm1.Open();
dmm2.Open();
dmm3.Open();
dmm4.Open();

TestCounter=1;
%% 变量初始化
TestVolCounter = 1;

store_count = 100000;
database1 = zeros(1,store_count);
database2 = zeros(1,store_count);
database3 = zeros(1,store_count);
database4 = zeros(1,store_count);
temp1arr  = zeros(1,store_count);
temp2arr  = zeros(1,store_count);

yyy = (database1:database2:database3:database4)';
%生成时间数组
t0 = datenum(datestr(now,0));
time_arr = repmat(t0,store_count, 1)
disp(time_arr(1));

test_step = 1
while(1)
    % 循环提示信息输出
    display(['当前文件测试次数',num2str(TestVolCounter)]);
    % 万用表数据采集
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
    %生成时间信息
    time_now = datestr(now,0);
    x_pick = datenum(time_now);
    x=x_pick;
    disp(time_now)
    time_arr(TestVolCounter*test_step-test_step+1:TestVolCounter*test_step,:) = x_pick;
    TestCounter=TestCounter+1;
    
    if(TestVolCounter == store_count/test_step)
        %% 创建记录文件
        filename = strcat(pwd,strcat(strcat('\data\',['芯片温度与电压关系',num2str(TestCounter),'_',datestr(now,30)]),'.mat'));
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
title('通道1电压');
ylabel('电压(V)');
hold on;
datetick('x', 0);
subplot(3,2,5);
plot(time_arr(1:1:TestVolCounter-1), database2(1:1:TestVolCounter-1), 'g.', 'MarkerSize', 6);
title('通道2电压');
ylabel('电压(V)');
xlabel('采样时间');
hold on;
datetick('x', 0)
subplot(3,2,4);
plot(time_arr(1:1:TestVolCounter-1), database3(1:1:TestVolCounter-1), 'b.', 'MarkerSize', 6);
title('通道3电压');
hold on;
datetick('x', 0);
subplot(3,2,6);
plot(time_arr(1:1:TestVolCounter-1), database4(1:1:TestVolCounter-1), 'k.', 'MarkerSize', 6);
title('通道4电压');
xlabel('采样时间');
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
title('芯片1温度');
ylabel('温度（℃）');
hold on;
datetick('x', 0);
subplot(3,2,2);
plot(time_arr(1:1:TestVolCounter-1), temp2arr(1:1:TestVolCounter-1), 'md', 'MarkerSize', 6);
title('芯片2温度');
hold on;
datetick('x', 0);

drawnow;
