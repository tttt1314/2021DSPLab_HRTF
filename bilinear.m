
clear
load 'ReferenceHRTF.mat' hrtfData sourcePosition;

hrtfData = permute(double(hrtfData),[2,3,1]);

sourcePosition = sourcePosition(:,[1,2]);
desiredAz = 0;
desiredEl = -90;
pre_bias = 180 - desiredAz;
sourcePosition(:, 1) = mod(sourcePosition(:,1) + pre_bias, 360);


desiredPosition = [desiredAz desiredEl];
figure
scatter(sourcePosition(:,1), sourcePosition(:,2));
title('hrtfData position');
xlabel('Azimuth(deg)');
ylabel('Elevation(deg)');
%% data remove
position_rm = desiredPosition + [pre_bias, 0];

radius = 3;
[hrtfData_rm, sourcePosition_rm] = position_remove(position_rm, radius, hrtfData, sourcePosition);

sourcePosition_rm(:,1) = mod(sourcePosition_rm(:,1) - pre_bias, 360);

figure
scatter(sourcePosition_rm(:,1), sourcePosition_rm(:,2));
title('hrtfData position');
xlabel('Azimuth(deg)');
ylabel('Elevation(deg)');
%% interpolation coordinate finding
sourcePosition_copy = sourcePosition_rm ;
sourcePosition_copy(:, 1) = mod(sourcePosition_copy(:,1) + pre_bias, 360); % pre-bias for distance caculated 

EL_des = desiredPosition(2);
AZ_des = desiredPosition(1);
sourcePosition_dis = sourcePosition_copy(:,2) - EL_des;
[EL1_dis, EL1_idx] = min(abs(sourcePosition_dis));
sourcePosition_dis(abs(sourcePosition_dis) ==  abs(sourcePosition_dis(EL1_idx))) = 999;
[~, EL2_idx] = min(abs(sourcePosition_dis));
sourcePosition_dis(sourcePosition_dis == 999) = EL1_dis;
sourcePosition_1 = sourcePosition_copy;
sourcePosition_2 = sourcePosition_copy;
for i = 1 : length(sourcePosition_copy)
    if(~(abs(sourcePosition_dis(i)) == abs(sourcePosition_dis(EL1_idx))))
        sourcePosition_1(i,:) = nan;
    end
    if(~(abs(sourcePosition_dis(i)) == abs(sourcePosition_dis(EL2_idx))))
        sourcePosition_2(i,:) = nan;
    end
end

[distance, indx_ab] = nearPosition(sourcePosition_1, desiredPosition  + [pre_bias, 0], 2);
interpolatedPos = sourcePosition_copy(indx_ab, :);

[distance, indx_c] = nearPosition(sourcePosition_2, desiredPosition + [pre_bias, 0], 1);
interpolatedPos = [interpolatedPos; sourcePosition_copy(indx_c, :)];

% debias
A = interpolatedPos(1,:)  - [pre_bias, 0]
B = interpolatedPos(2,:) - [pre_bias, 0]
C = interpolatedPos(3, :)- [pre_bias, 0]
D = [A;B;C];
h = figure();
scatter(D(:,1), D(:,2));
hold;
scatter(desiredAz, desiredEl, 'filled', 'r');
xlabel('Azimuth(deg)');
ylabel('Elevation(deg)');
ti = strcat('(', num2str(desiredAz),',', num2str(desiredEl), ')' ,' removed:', num2str(radius));
title(ti);
ti_2 = strcat(num2str(desiredAz),'_', num2str(desiredEl), '_' ,' rm_', num2str(radius));
fileout = strcat('.\newDatas\',ti_2, '.fig');
savefig(h, fileout);

phi_grid = C(2) - A(2);
theta_grid = B(1) - A(1);
phi = EL_des - A(2);
theta_a = AZ_des - A(1);
theta_ac = C(1) - A(1);

wc = phi/phi_grid;
wb = 1/theta_grid*(theta_a - wc*theta_ac);
wa = 1 - wb - wc;
ha = squeeze(hrtfData_rm(indx_ab(1) , : , :));
hb = squeeze(hrtfData_rm(indx_ab(2), : , :));
hc = squeeze(hrtfData_rm(indx_c, : , :));

hp = wa.*ha +wb.*hb + wc.*hc;

% for i = 1 : length(sourcePosition)
%     if(sourcePosition_(i,1) == A(1), sourcePosition(i,2) == A())
% end

%interpolatedIR  = HRTFinterpolation(hrtfData,sourcePosition,desiredPosition);

% interpolatedIR  = interpolateHRTF(hrtfData_rm,sourcePosition_rm,desiredPosition,"Algorithm","VBAP");
% 
% leftIR = squeeze(interpolatedIR(:,1,:))';
% rightIR = squeeze(interpolatedIR(:,2,:))';
leftIR = hp(1,:);
rightIR = hp(2,:);
%% render plot
dF = 48000/length(leftIR);
figure
plot(dF*[-length(leftIR)/2 : length(leftIR)/2-1],fftshift(mag2db(abs(fft(leftIR)))));
hold
plot(dF*[-length(leftIR)/2 : length(leftIR)/2-1],fftshift(mag2db(abs(fft(rightIR)))));
xlim([-20000,20000]);
legend('left','right');
xlabel('Frequency(Hz)');
ylabel('Magnitude(dB)');
title('magnitude');
figure
plot(dF*[-length(leftIR)/2 : length(leftIR)/2-1],fftshift(unwrap(angle(fft(leftIR)))));
hold
plot(dF*[-length(leftIR)/2 : length(leftIR)/2-1],fftshift(unwrap(angle(fft(rightIR)))));
xlim([-20000,20000]);
legend('left','right');
xlabel('Frequency(Hz)');
ylabel('Phase');
title('Phase');

%%



% dF = 48000/length(leftIR);
% figure
% plot(dF*[-length(leftIR)/2 : length(leftIR)/2-1],fftshift(fft(leftIR)));
% hold
% plot(dF*[-length(leftIR)/2 : length(leftIR)/2-1],fftshift(fft(rightIR)));
% legend('left','right');

filename = strcat('newDatas/', num2str(desiredAz),'_', num2str(desiredEl),'_rm', num2str(radius) , '.wav');
fileReader = dsp.AudioFileReader('RockDrums-48-stereo-11secs.mp3');
afw = dsp.AudioFileWriter(filename, 'SampleRate', fileReader.SampleRate);
deviceWriter = audioDeviceWriter('SampleRate',fileReader.SampleRate);

leftFilter = dsp.FIRFilter('Numerator',leftIR);
rightFilter = dsp.FIRFilter('Numerator',rightIR);

while ~isDone(fileReader)
    audioIn = fileReader();
    
    leftChannel = leftFilter(audioIn(:,1));
    rightChannel = rightFilter(audioIn(:,2));
    output = [leftChannel,rightChannel];
    deviceWriter(output);
    afw(output);
end

release(afw);
release(fileReader);

