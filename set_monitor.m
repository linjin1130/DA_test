clc;
clear all;
%%
dac_ip='10.0.2.2';
monitor_para = [1, 10]
dac = USTCDAC(dac_ip,80);
dac.Open();%%%ע�⣺ȷ��open��û��init�����������Ӱ������������
dac.SetBoardcast(1, 10);
display('����DA�����ɹ�');
dac_ip 
monitor_para
dac.Close();

