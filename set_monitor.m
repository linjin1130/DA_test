%%
function set_monitor(dac_ip, enable_disable, period)
	dac = USTCDAC(dac_ip,80);
	dac.Open();%%%ע�⣺ȷ��open��û��init�����������Ӱ������������
	dac.SetBoardcast(enable_disable, period);
	display('����DA�����ɹ�',dac_ip);
	dac.Close();
end

