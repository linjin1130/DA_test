% author:linjin
% data:2017/6/5
% version:1.0
% filename:board_scan.m
% describe:测试DA板4个通道的扫码输出
% 测试方法：
% 1. 打开DA
% 2. 校准增益
% 3. 校准偏置
% 4. 设置起点为0
% 5. 设置步长
% 6. 设置电压记录数组
% 7. 主循环直到最大值
%    7.1 设置默认电压值
%    7.2 测量电压
% 8. 保存matlab文件、
%% 系统校正目标值
dac_ip='10.0.2.2';
dmm1_ip='10.0.254.3';
dmm2_ip='10.0.254.4';
dmm3_ip='10.0.254.5';
dmm4_ip='10.0.254.6';

dac_ch=1;
%% 系统参数校正
GainCode   =zeros(1,4);
GainVoltage =zeros(1,4);
OffsetCode =zeros(1,4);
OffsetVoltage=zeros(1,4);
target_volt = 1.6;
%%
[GainCode,GainVoltage,OffsetCode,OffsetVoltage]=GainOffsetCorrect(dmm1_ip,dmm2_ip,dmm3_ip,dmm4_ip,dac_ip,80, target_volt);
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
dac.SetGain(1,GainCode(1));
dac.SetGain(2,GainCode(2));
dac.SetGain(3,GainCode(3));
dac.SetGain(4,GainCode(4));
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
step = 10000;
store_count = floor(65536/step);
database1 = zeros(1,store_count);
database2 = zeros(1,store_count);
database3 = zeros(1,store_count);
database4 = zeros(1,store_count);
temp1arr  = zeros(1,store_count);
temp2arr  = zeros(1,store_count);

yyy = (database1:database2:database3:database4)';
%生成时间数组
t0 = datenum(datestr(now,0));
time_arr = repmat(t0,store_count, 1);
dac.SetDefaultVolt(1, 0);
dac.SetDefaultVolt(2, 0);
dac.SetDefaultVolt(3, 0);
dac.SetDefaultVolt(4, 0);
test_step = 1;
while(test_step<=store_count)
    % 循环提示信息输出
    display(['当前测试码值',num2str(test_step*step)]);
    % 万用表数据采集
    dmm1_value=dmm1.measure_count(1);
    dmm2_value=dmm2.measure_count(1);
    dmm3_value=dmm3.measure_count(1);
    dmm4_value=dmm4.measure_count(1);
    %测量温度
    temp1 = dac.GetDA1_temp();
    temp2 = dac.GetDA2_temp();
    %存储数据 温度
    database1(test_step) = dmm1_value(:);
    database2(test_step) = dmm2_value(:);
    database3(test_step) = dmm3_value(:);
    database4(test_step) = dmm4_value(:);
    temp1arr(test_step) = temp1;
    temp2arr(test_step) = temp2;
    delta_ab = dmm2_value - dmm1_value + 0.64;
    delta_ac = dmm3_value - dmm1_value + 0.64;
    delta_ad = dmm4_value - dmm3_value + 0.64;
    %生成时间信息
    time_now = datestr(now,0);
    x_pick = datenum(time_now);
    x=x_pick;
    disp(time_now)
    time_arr(test_step) = x_pick;
    dac.SetDefaultVolt(1, test_step*step);
    dac.SetDefaultVolt(2, test_step*step);
    dac.SetDefaultVolt(3, test_step*step);
    dac.SetDefaultVolt(4, test_step*step);
    test_step=test_step+1;
end

%% 创建记录文件
filename = strcat(pwd,strcat(strcat('\data\',['芯片温度与电压关系',num2str(TestCounter),'_',datestr(now,30)]),'.mat'));
save('filename.mat');
movefile('fileName.mat',filename); 
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
plot(time_arr(1:1:TestCounter-1), database1(1:1:TestCounter-1), 'r.', 'MarkerSize', 6);
title('通道1电压');
ylabel('电压(V)');
hold on;
datetick('x', 0);
subplot(3,2,5);
plot(time_arr(1:1:TestCounter-1), database2(1:1:TestCounter-1), 'g.', 'MarkerSize', 6);
title('通道2电压');
ylabel('电压(V)');
xlabel('采样时间');
hold on;
datetick('x', 0)
subplot(3,2,4);
plot(time_arr(1:1:TestCounter-1), database3(1:1:TestCounter-1), 'b.', 'MarkerSize', 6);
title('通道3电压');
hold on;
datetick('x', 0);
subplot(3,2,6);
plot(time_arr(1:1:TestCounter-1), database4(1:1:TestCounter-1), 'k.', 'MarkerSize', 6);
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
plot(time_arr(1:1:TestCounter-1), temp1arr(1:1:TestCounter-1), 'cs', 'MarkerSize', 6);
title('芯片1温度');
ylabel('温度（℃）');
hold on;
datetick('x', 0);
subplot(3,2,2);
plot(time_arr(1:1:TestCounter-1), temp2arr(1:1:TestCounter-1), 'md', 'MarkerSize', 6);
title('芯片2温度');
hold on;
datetick('x', 0);

drawnow;
