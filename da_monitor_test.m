% author:linjin
% data:2017/6/5
% version:1.0
% filename:da_monitor.m
% describe:设置DA板的监测参数
% 测试方法：enable=1表示使能监视，enable=0表示禁止监视
% period 表示监视周期时间单位为100ms

%%
ip = '10.0.2.1';
enable = 1;
period = 20;
set_monitor(ip, enable, period);

