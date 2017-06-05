% author:linjin
% data:2017/5/23
% version:1.0
% filename:temperature_relationship.m
% describe:��ͬһ��DA���4��ͨ��У׼ΪĿ���ѹֵ
%%

function [ GainCode,GainVoltage,OffsetCode,OffsetVoltage ] = GainOffsetCorrect(dmm1_ip,dmm2_ip,dmm3_ip,dmm4_ip, dac_ip,port)
    %Detailed explanation goes here
    GainCode   =zeros(1,4);
    GainVoltage =zeros(1,4);
    OffsetCode =zeros(1,4);
    OffsetVoltage=zeros(1,4);
    dac_ch=1;
    gain_set=1.28;
    offset_set=0;
    %% ���桢ƫ��У��
    dac = USTCDAC(dac_ip,port);
    dac.Open();
    display('DAC Init...');
    dac.InitBoard();
    dac.PowerOnDAC(1,0);
    dac.PowerOnDAC(2,0);
    dac.StartStop(240);
    %% ���ñ�����
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
        %% ϵͳУ��,����¼����
        display('����У��...');
        %% ���������ģʽ����ʼ���
        %% ִ������У���㷨
       
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
        while(0 ~=error && v_h < 2)
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
                display(strcat('����У������,offset=',num2str(gain)));
                gain = 0;
                break;
            end
            loop_counter=loop_counter+1;
        end
        GainCode(dac_ch) = gaincode(gain);
        GainVoltage(dac_ch) = voltage;
        display('ƫ��У��...');
        %% ��dac����Ϊ0�������
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

