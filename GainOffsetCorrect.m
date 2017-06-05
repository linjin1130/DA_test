function [ GainCode,GainVoltage,OffsetCode,OffsetVoltage ] = GainOffsetCorrect(dmm1_ip,dmm2_ip,dmm3_ip,dmm4_ip, dac_ip,port, target_volt)
    %Detailed explanation goes here
    GainCode   =zeros(1,4);
    GainVoltage =zeros(1,4);
    OffsetCode =zeros(1,4);
    OffsetVoltage=zeros(1,4);
    dac_ch=1;
    gain_set=target_volt;
    offset_set=0;
    %% 增益、偏置校正
    dac = USTCDAC(dac_ip,port);
    dac.Open();
    display('DAC Init...');
    dac.InitBoard();
    dac.PowerOnDAC(1,0);
    dac.PowerOnDAC(2,0);
    dac.StartStop(240);
    %% 万用表设置
    dmm1 = DMM34465A(dmm1_ip);
    dmm2 = DMM34465A(dmm2_ip);
    dmm3 = DMM34465A(dmm3_ip);
    dmm4 = DMM34465A(dmm4_ip);
    dmm1.Open();
    dmm2.Open();
    dmm3.Open();
    dmm4.Open();
    while(dac_ch<5)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 系统校正,并记录数据
        display('增益校正...');
        %% 将设置输出模式并开始输出
%         waveobj = waveform();
%         seq  = waveobj.generate_seq(32);
%         dac.WriteSeq(dac_ch,0,seq);
%         dac.StartStop(2^(dac_ch-1));
%         dac.CheckStatus();
        
        %% 执行增益校正算法
       
        if(dac_ch==1)
            dmm=dmm1;
        end
        if(dac_ch==2)
            dmm=dmm2;
        end
        if(dac_ch==3)
            dmm=dmm3;
        end
        if(dac_ch==4)
            dmm=dmm4;
        end
        dac.SetGain(dac_ch,511);
%         dac.CheckStatus();
        dac.SetDefaultVolt(dac_ch, 65535);
        v_h = measure_vpp(dmm,dac,dac_ch);
        disp(v_h)
        dac.SetGain(dac_ch,512);
%         dac.CheckStatus();
        v_l = measure_vpp(dmm,dac,dac_ch);
        disp(v_l)
        slope = (v_h - v_l)/1023;
        gaincode = [512:1023,0:511]; 
        error = -1;
        gain = 513;
        loop_counter=0;
        while(0 ~=error)
            dac.SetGain(dac_ch,gaincode(gain));
            dac.CheckStatus();
            voltage = measure_vpp(dmm,dac,dac_ch);
            error = floor((voltage - gain_set)/slope + 0.5);
            gain = gain - error;
            if(gain>1023 || gain<0)
                dac.Close();
                dmm1.Close();
                dmm2.Close();
                dmm3.Close();
                dmm4.Close();
                display(strcat('增益校正出错,offset=',num2str(gain)));
                gain = 513;
                break;
            end
            loop_counter=loop_counter+1;
        end
        GainCode(dac_ch) = gaincode(gain);
        GainVoltage(dac_ch) = voltage;
        display('偏移校正...');
        %% 将dac设置为0幅度输出
        OffsetCode(dac_ch)=0;
        dac.SetDefaultVolt(dac_ch, 0);
        voltage = dmm.measure();
        OffsetVoltage(dac_ch)=voltage;
        dac_ch=dac_ch+1;
    end  
    %%
    dac.StartStop(240);
    dac.Close();
    dmm1.Close();
    dmm2.Close();
    dmm3.Close();
    dmm4.Close();
end

