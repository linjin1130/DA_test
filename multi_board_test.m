repeat_cnt = 1000000;
da_ip = {'10.0.4.23'}%,'10.0.3.1','10.0.3.17','10.0.2.5','10.0.3.13'};

for ip = da_ip
    da = USTCDAC(char(ip),80);
    da.set('ismaster',1);
     da.set('trig_interval',60e-6);
    da.Open()
%     da.InitBoard();
%     da.Close();
%     pause(10);
%     da.Open();
    da.StartStop(240);
    da.SetTrigCount(8);
    da.SetTrigSel(0);
    da.SetTrigDelay(0);
    waveobj = waveform();
    waveobj.frequency = ceil(waveobj.sample_rate/100000);
    waveobj.amplitude = 65535;
    waveobj.offset = 32768;
    wave = waveobj.generate_sine();
    cnt = 0;
    seq = waveform.generate_trig_seq(length(wave),0);
%     seq = seq(1:200);
    while(cnt < repeat_cnt)
        tic
        for k = 1:4
            da.WriteWave(k,0,wave);
            da.WriteSeq(k,0,seq);
        end
        da.CheckStatus();
        cnt=cnt+1;
        disp(cnt);
        da.StartStop(15);
        da.SendIntTrig();
        
        pause(0.2);
        toc
        

    end
    tic
    da.CheckStatus();
    toc
    da.StartStop(240);
    
    %%
    da.Close();
    disp('Íê³É');
end