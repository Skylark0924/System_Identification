% This file is used to generate the input data for system identification.
clear; clc; close all;
%% Generate the sweep wave.
f_sample = 500; % Sampling frequency is 500Hz
Time = 50;
N = f_sample*Time;% sweep wave sample numbers
t = 0:1/f_sample:(N-1)/f_sample;% sweep wave time instants
ampl = 1500; % the amplitude of the sweep wave
sweep_wave = ampl.*chirp(t,0,50,6,'linear',-90); % generate 0-10Hz sweep wave
sweep_wave = sweep_wave'; % tranpose the array
for i = 1:f_sample*Time
    if abs(sweep_wave(i)) <= 1e-9
        sweep_wave(i) = 0;
    end
end
sweep_wave_str = num2str(sweep_wave);% convert number to string



for i = 1:f_sample*Time
    sweep_wave_cell{i} = {sweep_wave_str(i,1:12)};% convert the string to the cell array
end
for i = 1:f_sample*Time
    sweep_wave_str1(i) = strcat(sweep_wave_cell{i},',');% add the comma between the array elements
end

%% Plot time-series data and frequency-domain data.
% format short;
f = linspace(0,f_sample,N);
figure(1);
plot(t(1:N), sweep_wave(1:N)); % display the time-series data
xlim([0 50]);
figure(2);
sweep_wave_fft = fft(sweep_wave);
plot(f,abs(sweep_wave_fft(1:N)));% display the frequency-domain data
xlim([0 20]);

%% Write the sweep_wave to txt file.
filename = 'sweep_wave_500_50s_0_6Hz.txt';
dlmwrite(filename,sweep_wave_str1,'delimiter','','precision',5);


