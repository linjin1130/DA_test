% author:linjin
% data:2017/6/5
% version:1.0
% filename:da_monitor.m
% describe:����DA��ļ�����
% ���Է�����enable=1��ʾʹ�ܼ��ӣ�enable=0��ʾ��ֹ����
% period ��ʾ��������ʱ�䵥λΪ100ms

%%
ip = '10.0.2.1';
enable = 1;
period = 20;
set_monitor(ip, enable, period);

