%% Biostatistics and Signal Processing
% Author: Lauryn Peters
% Date: January 26, 2024

%% Part 1
% Importing Biometrics 

% Loads heart rate, hours of sleep, and number of steps into memory
Table1 = readtable('AMV7EQF_hr.csv');
Table2 = readtable('AMV7EQF_sleep.csv');
Table3 = readtable('AMV7EQF_steps.csv');

%% Calculates Mean of Column of Interest

% Calculates the mean
mean1 = mean(Table1.heartrate,'omitnan');
mean2 = mean(Table2.stage_duration,'omitnan');
mean3 = mean(Table3.steps,'omitnan');

% Calculates the mode
mode1 = mode(Table1.heartrate, 'all');
mode2 = mode(Table2.stage_duration, 'all');
mode3 = mode(Table3.steps, 'all');

% Calculates the median
median1 = median(Table1.heartrate, 'all');
median2 = median(Table2.stage_duration, 'all');
median3 = median(Table3.steps, 'all');

% Calculates the range
min1 = min(Table1.heartrate);
min2 = min(Table2.stage_duration);
min3 = min(Table3.steps);

max1 = max(Table1.heartrate);
max2 = max(Table2.stage_duration);
max3 = max(Table3.steps);

range1 = max1 - min1;
range2 = max2 - min2;
range = max3 - min3;

% Calculates the standard deviation
sd1 = std(Table1.heartrate, 'omitnan');
sd2 = std(Table2.stage_duration, 'omitnan');
sd3 = std(Table3.steps, 'omitnan');

%% Find Correlation Between Columns in Table1 & Table3

% We can't do this directly because the recordings are taken at different
% times, so the first thing that we will need to do is create new tables
% with only the times at which there is a value for both variables.

% Places a '1' in the 'idxT_' vector where there is a reading at a matching 
% time
[idxT3,~] = ismember(Table3.datetime,Table1.datetime);
[idxT1,~] = ismember(Table1.datetime, Table3.datetime);

% Finds the indices where each of these matching times are
idxT3 = find(idxT3);
idxT1 = find(idxT1);

% Creates new tables with matching datetime vectors
NewTable1 = Table1(idxT1,:);
NewTable3 = Table3(idxT3,:);

% Finds the correlation coefficient between the 2 recordings
c = corrcoef(NewTable1.heartrate, NewTable3.steps);


%% Part 2 - Section A
% Recording Audio

% creates an object to store the audio sample in 
recObj = audiorecorder(44100,8,1); 

recDuration = 3; % 3 second recording
disp("Begin speaking.")
recordblocking(recObj,recDuration);
disp("End of recording.")

%% Plotting Audio

% transforms audio into a vector of discrete data
myRecording = getaudiodata(recObj);  

figure;
plot1 = plot(myRecording); % Plots your recording
title('Audio Recording'); % The title of graph

%% Downsampling

% downsamples audio by a factor of 44 to get a sample frequency of ~ 1 kHz
downs = downsample(myRecording, 44); 
sound(downs, 44100/44)

figure;
plot2 = plot(downs);
title('Downsampled Audio'); 

% Plotting Tiled Graphs

tiledlayout(1,2);
sgtitle("Audio Comparison");

% Tile 1
nexttile
plot(myRecording)
title('Original Audio')
xlabel('Time (s)')
ylabel('Amplitude')

% Tile 2
nexttile
plot(downs)
title('Downsampled Audio')
xlabel('Time (s)')
ylabel('Amplitude')

%% Part 2 - Section B
% Processing Audio

% specify parameters 
Fs = 44100; %s sample rate
T = 1/Fs; % period of signal 
L = 132300; % length of signal vector 
t = (0:L-1)*T; % time vector 

four = fft(myRecording); % fourier transform of original audio

% plot complex magnitude of fft spectrum 
figure(2)
plot(Fs/L*(0:L-1),abs(four))
title("Complex Magnitude of fft Spectrum")
xlabel("f (Hz)")
ylabel("|fft(myRecording)|")

% plot + and - frequencies
figure(3)
plot(Fs/L*(-L/2:L/2-1),abs(fftshift(four)))
title("fft Spectrum in the Positive and Negative Frequencies")
xlabel("f (Hz)")
ylabel("|fft(myRecording)|")

% convert to single sided spectrum
P2 = abs(four/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% plot single sided amplitude
f = Fs/L*(0:(L/2));
figure(4)
plot(f,P1) 
title("Single-Sided Amplitude Spectrum of myRecording(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")

%% Part 2 - Section C 
% Adding Noise and Reprocessing 

play(recObj); % play original sounds recording
noise = awgn(myRecording, -5); % AWGN = Add Gaussian White Noise
sound(noise, 44100); % play noisy sound recording

%% Plotting Noisy Audio

figure(5)
plot(noise)
title('Noisy Audio in Time Domain')
xlabel('Time (s)')
ylabel('Amplitude')

figure(6)
plot(abs(fft(noise)))
title('Noisy Audio in Frequency Domain')
xlabel('f (Hz)')
ylabel('|fft(noise)|')

%% Designing a FIR Filter

Fp = 300; % the value where the orginal audio frequency begins to drop off
Fst = 350; % so that it is set after the highest frequency of interest 

firfilt = designfilt('lowpassfir', 'SampleRate', Fs,...
'PassbandFrequency', Fp, 'StopbandFrequency', Fst,...
'PassbandRipple', 1, 'StopbandAttenuation', 95);

filtNoise = filter(firfilt, noise); % filtered audio
filteredFourier = fft(filtNoise); % FT of filtered audio

% plotting filtered audio 

figure(7)
plot(filtNoise)
title ("Filtered Audio in the Time Domain")
xlabel('Time (s)')
ylabel('Amplitude')

% convert to single sided spectrum
P2_filter = abs(filteredFourier/L);
P1_filter = P2_filter(1:L/2+1);
P1_filter(2:end-1) = 2*P1_filter(2:end-1);
f_filter = Fs/L*(0:(L/2));

% plot single sided amplitude
figure(8)
plot(f_filter,P1_filter) 
title("Single-Sided Amplitude Spectrum of Filtered Audio")
xlabel("f (Hz)")
ylabel("|P1_filter(f)|")
