% Load data
load 'ReferenceHRTF.mat' hrtfData sourcePosition
fileReader = dsp.AudioFileReader('konoseiga.mp3');

% Write File
% afw = dsp.AudioFileWriter...
%    ('..\result\test.wav', ...
%    'SampleRate', fileReader.SampleRate);

% Real time Audio Ouput
deviceWriter = audioDeviceWriter('SampleRate',fileReader.SampleRate);

% Pre-process
hrtfData = permute(double(hrtfData),[2,3,1]);
sourcePosition = sourcePosition(:,[1,2]);

% Create an object of a handle class
x = parameterRef;
x.name = 'Theta';
x.value = 0;

y = parameterRef;
y.name = 'tho';
y.value = 0;

% Open the UI function for your parameter
parameterTuningUI(x,-180,180);
parameterTuningUI(y,-90,90);

i = 0;
j = 0;

%real time 
while ~isDone(fileReader)
    audioIn = fileReader();
    
    if mod(j, 20) == 0
        i = mod(i - 20, 360);
        drawnow limitrate
        desiredAz = mod(360-x.value, 360);
        desiredEl = mod(180+y.value, 180);
        desiredPosition = [desiredAz desiredEl];
%     desiredPosition = [i 0];

        interpolatedIR  = bilinear_func(hrtfData,sourcePosition,desiredPosition);


        leftIR = squeeze(interpolatedIR(1,:));
        rightIR = squeeze(interpolatedIR(2,:));

        leftFilter = dsp.FIRFilter('Numerator',leftIR);
        rightFilter = dsp.FIRFilter('Numerator',rightIR);
    end
    
    leftChannel = leftFilter(audioIn(:,1));
    rightChannel = rightFilter(audioIn(:,2));
    output = [leftChannel,rightChannel];
% afw(output)
    deviceWriter(output);
    j = mod(j + 1, 20);
end
% release(afw)
release(deviceWriter)
release(fileReader)
