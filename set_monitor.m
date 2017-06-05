clc;
clear all;
%%
dac_ip='10.0.2.2';
monitor_para = [1, 10]
dac = USTCDAC(dac_ip,80);
dac.Open();%%%注意：确保open中没有init操作，否则会影响主测试任务
dac.SetBoardcast(1, 10);
display('设置DA参数成功');
dac_ip 
monitor_para
dac.Close();

