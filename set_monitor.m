
function SetDAMonitor(dac_ip, enable_disable, period)
	dac = USTCDAC(dac_ip,80);
	dac.Open();%%%注意：确保open中没有init操作，否则会影响主测试任务
	dac.SetBoardcast(enable_disable, period);
	display('设置DA参数成功');
	dac.Close();
end

%%
ip = '10.0.2.2';
enable = 1;
period = 10;
SetDAMonitor(ip, enable, period);
