function EMG = gen_EMG(u)
%    %I'm just using a simple model for now. It contains both multiplicative and additive noise.
%    EMG = u + .4*randn(size(u)).*u + .1*randn(size(u));
%    %AGA: 0.4* multiplicative noise; 0.1* additive noise

%%High Speed Clancy Model
% ts=0.01;%sampling rate

global noisebank; %just pick random values from the bank instead of generating new numbers everytime- saves a lot of computational time

Startpoints= 1+ round((98000-1).*rand(2,1));%this is faster than the random sample function

addNoise=noisebank(Startpoints(1):(Startpoints(1)+length(u)-1));
mulNoise = noisebank(Startpoints(2):(Startpoints(2)+length(u)-1));

ns = 1.1*addNoise' + 0.7*u.*mulNoise';
EMG = u + movmean(ns,min(length(u),120)); %if the length of u is smaller than 120, window should be the length of the signal
end