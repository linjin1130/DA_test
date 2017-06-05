% author:Jin.Lin
% data:2017/5/18
% version:1.0
% filename:reconfig_da_chip.m
% describe:DA芯片重配置
%%
%系统校正目标值
dac_ip='10.0.2.2';
dac = USTCDAC(dac_ip,80);
dac.Open();
dac.InitBoard();
display('DAC Init...');
dac.Close();