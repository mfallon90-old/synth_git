function Note = FmSynth(Fs, FCarHz, FModFrac, ModTau, Ampl, FModDecayType, AmplTau, ModIndex, NumSamp)
% Fs = 44100;         % Sample rate (Hz)
% FCarHz = 880;       % Frequency of the note.
% FModHz = 110;       % Modulation Frequency. Determines harmonic spacing from carrierr.
% Tau = 0.5;          % Decay time constant for the modulation.
% DecayType = 0;      % Zero decreases modulation during note. One increases.
% ModIndex = 3;       % Mod index, Beta.
% NoteDurSec = 1;     % Note duration.

BitsNco = 32;     	% NCO bits

AlphaMod = 1 - 1/(ModTau * Fs);           % Feedback constant for lowpass filter for modulation.
AlphaAmpl = 1 - 1/(AmplTau * Fs);           % Feedback constant for lowpass filter for Amplitude shaping.

IncrCar = 2^BitsNco * FCarHz/Fs;    % Increment per clock cycle to create carrier frequency.
FModHz = FCarHz*FModFrac;

Note = zeros(NumSamp, 1); 	% Declare the Output Array
Nco = 0;                    % Initialize the recursion
EnvFilt = 0;                % Initialize the recursion 
AmplFilt = 0;

DevScaleArray = ones(NumSamp, 1);  % Saving only so the envelope can be plotted.

% Run the system
for k = 2 : NumSamp
    EnvFiltSave = EnvFilt;              % Store the last value.
    EnvFilt = 1 + EnvFiltSave * AlphaMod;  % Increase modulation with time
    
    if FModDecayType == 0
        DevScale = 1 -(EnvFiltSave + EnvFilt) * (1-AlphaMod)/2;    % Start at full modulation and decay  
    else
        DevScale = (EnvFiltSave + EnvFilt) * (1-AlphaMod)/2;       % Start at full modulation and decay 
    end

    DevScaleArray(k) = DevScale;
    Nco = Nco + IncrCar + DevScale*FModHz*ModIndex*2^(BitsNco)/Fs * cos(2*pi*FModHz*k/Fs);
    Note(k) = Ampl*cos(2*pi*Nco/2^BitsNco);         % Frequency modulated
    
 	AmplFiltSave = AmplFilt;              % Store the last value.
    AmplFilt = 1 + AmplFiltSave * AlphaAmpl;  % Increase modulation with time
    AmplScale = 1 - (AmplFiltSave + AmplFilt) * (1-AlphaAmpl)/2;       % Start at full modulation and decay 
    Note(k) = Note(k) * AmplScale;
    
end



% figure(1);
% plot(DevScaleArray);
% 
% t = (1 : NumSamp)/Fs;
% 
% 
% H = dsp.SpectrumAnalyzer('SampleRate', Fs,  'PlotAsTwoSidedSpectrum', false, 'RBWSource', 'Property', 'RBW', 1, ...
%     'PowerUnits', 'dBW','FrequencySpan','Start and stop frequencies', 'StartFrequency', 0, 'StopFrequency', 20000);
% step(H,Out);
% 
% Leader = zeros(10000, 1);
% Note = [Leader; Out];
% 
% 
% % figure(2);
% % plot(t, Out);
% 
% % sound(Out, Fs, 16);
% player = audioplayer(Out,44100,16);
% play(player);
