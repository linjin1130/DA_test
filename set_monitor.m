
function SetDAMonitor(dac_ip, enable_disable, period)
	dac = USTCDAC(dac_ip,80);
	dac.Open();%%%ע�⣺ȷ��open��û��init�����������Ӱ������������
	dac.SetBoardcast(enable_disable, period);
	display('����DA�����ɹ�');
	dac.Close();
end

%%
ip = '10.0.2.2';
enable = 1;
period = 10;
SetDAMonitor(ip, enable, period);
