%%
load 'ReferenceHRTF.mat' hrtfData sourcePosition
fileReader = dsp.AudioFileReader('Counting-16-48-mono-15secs.wav');
deviceWriter = audioDeviceWriter('SampleRate',fileReader.SampleRate);
afw = dsp.AudioFileWriter('../data/clockwise.wav', 'SampleRate', fileReader.SampleRate);

sourcePosition = sourcePosition(:,[1,2]);
desiredAz = 135;
desiredEl =0;
desiredPosition = [desiredAz desiredEl];
hrtfData = permute(double(hrtfData),[2,3,1]);
%%


i = 0;
j = 0;
while ~isDone(fileReader)
    audioIn = fileReader();
    if mod(j, 30) == 0;
%         i = mod(i - 20, 360);
%         desiredAz = i;
%         desiredEl = 0;
        desiredPosition = [desiredAz desiredEl];

        interpolatedIR  = bilinear_func(hrtfData,sourcePosition,desiredPosition);


        leftIR = squeeze(interpolatedIR(1,:));
        rightIR = squeeze(interpolatedIR(2,:)); 
        leftFilter = dsp.FIRFilter('Numerator',leftIR);
        rightFilter = dsp.FIRFilter('Numerator',rightIR);
    end
    leftChannel = leftFilter(audioIn(:,1));
    rightChannel = rightFilter(audioIn(:,2));
    output = [leftChannel,rightChannel];
    deviceWriter(output);
%     afw(output);
    j = mod(j + 1, 30);
end
% release(afw);
release(fileReader);