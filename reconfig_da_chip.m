% author:Jin.Lin
% data:2017/5/18
% version:1.0
% filename:reconfig_da_chip.m
% describe:DAоƬ������
%%
%ϵͳУ��Ŀ��ֵ
dac_ip='10.0.2.2';
dac = USTCDAC(dac_ip,80);
dac.Open();
dac.InitBoard();
display('DAC Init...');
dac.Close();