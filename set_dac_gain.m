% author:linjin
% data:2017/6/5
% version:1.0
% filename:set_dac_gain.m
% describe:设置DA板的增益
% 测试方法：
% 
%%
ip = '10.0.2.1';
dac = USTCDAC(ip,80);
dac.Open();
display('DAC Init...');
dac.SetGain(1,511);
pause(0.2);
dac.SetGain(2,511);
pause(0.2);
dac.SetGain(3,511);
pause(0.2);
dac.SetGain(4,511);
pause(0.2);
dac.Close();
display('finish');