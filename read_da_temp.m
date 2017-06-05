clc;
clear all;
%%
dac_ip='10.0.2.2';
monitor_para = [1, 10]
dac = USTCDAC(dac_ip,80);
dac.Open();%%%注意：确保open中没有init操作，否则会影响主测试任务
%%
temp1 = dac.GetDA1_temp()
temp2 = dac.GetDA2_temp()
%%
tt1 = dac.ReadAD9136_1(hex2dec('132'));
tt2 = dac.ReadAD9136_1(hex2dec('133'));
display('设置DA参数成功');
tt1 = mod(tt1,256)
tt2 = mod(tt2,256)

temp = 30+7.3*(tt2*256+tt1-39200)/1000.0
dac.Close();

function temp = ReadDA1_temp(dac, num)
    tt1 = dac.ReadAD9136_1(hex2dec('132'));
    tt2 = dac.ReadAD9136_1(hex2dec('133'));
    tt1 = mod(tt1,256)
    tt2 = mod(tt2,256)
    temp = 30+7.3*(tt2*256+tt1-39200)/1000.0;
end

function temp = ReadDA2_temp(dac, num)
    tt1 = dac.ReadAD9136_2(hex2dec('132'));
    tt2 = dac.ReadAD9136_2(hex2dec('133'));
    tt1 = mod(tt1,256)
    tt2 = mod(tt2,256)
    temp = 30+7.3*(tt2*256+tt1-39200)/1000.0;
end