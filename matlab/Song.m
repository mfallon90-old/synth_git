clearvars;
close all;

C1 = 256;
C0 = C1 * 2^(-12/12);
C0s = C1 * 2^(-11/12);
D0 = C1 * 2^(-10/12);
E0b = C1 * 2^(-9/12);
E0 = C1 * 2^(-8/12);
F0 = C1 * 2^(-7/12);
F0s = C1 * 2^(-6/12);
G0 = C1 * 2^(-5/12);
G0s = C1 * 2^(-4/12);
A0 = C1 * 2^(-3/12);
A0s = C1 * 2^(-2/12);
B0 = C1 * 2^(-1/12);
C1s = C1 * 2^(1/12);
D1 = C1 * 2^(2/12);
E1b = C1 * 2^(3/12);
E1 = C1 * 2^(4/12);
F1 = C1 * 2^(5/12);
F1s = C1 * 2^(6/12);
G1 = C1 * 2^(7/12);
G1s = C1 * 2^(8/12);
A1 = C1 * 2^(9/12);
A1s = C1 * 2^(10/12);
B1 = C1 * 2^(11/12);
C2 = C1 * 2^(12/12);
C2s = C1 * 2^(13/12);
D2 = C1 * 2^(14/12);
E2b = C1 * 2^(15/12);
E2 = C1 * 2^(16/12);
F2 = C1 * 2^(17/12);
F2s = C1 * 2^(18/12);
G2 = C1 * 2^(19/12);
G2s = C1 * 2^(20/12);
A2 = C1 * 2^(21/12);
A2s = C1 * 2^(22/12);
B2 = C1 * 2^(23/12);
C3 = C1 * 2^(24/12);
C3s = C1 * 2^(25/12);
D3 = C1 * 2^(26/12);
E3b = C1 * 2^(27/12);
E3 = C1 * 2^(28/12);
F3 = C1 * 2^(29/12);
F3s = C1 * 2^(30/12);
G3 = C1 * 2^(31/12);
G3s = C1 * 2^(32/12);
A3 = C1 * 2^(33/12);
A3s = C1 * 2^(34/12);
B3 = C1 * 2^(35/12);


Fs = 44100;

BPM = 120;

ClksPerBeat = round(Fs * 60/BPM);

Whole = round(ClksPerBeat * 4);
Half = round(ClksPerBeat * 2);
Quarter = round(ClksPerBeat * 1);
Eighth = round(ClksPerBeat * 0.5);
DottedHalf = round(Half * 1.5);


Time = 1; % Current time in clock ticks.

% Chorus 1
NoteDur = Eighth;
x = FmSynth(Fs, G3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, E3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, C3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, G2,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, E2,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, G2,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, C3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, E3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, F3s,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, D3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, A2,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, F2s,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;


NoteDur = Eighth;
x = FmSynth(Fs, D2,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, F2s,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, A2,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, D3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, G3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
x2 = FmSynth(Fs, G3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 +x2;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, G3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
x2 = FmSynth(Fs, G3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 +x2;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, G3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
x2 = FmSynth(Fs, F3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
x3 = FmSynth(Fs, A2,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 +x2 + x3;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, G3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
x2 = FmSynth(Fs, F3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
x3 = FmSynth(Fs, A2,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 +x2 + x3;
Time = Time + NoteDur;

NoteDur = Eighth;
x1 = FmSynth(Fs, E3,0.5, 0.5, 0.6, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, C3,0.5, 0.5, 0.18, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, G1,0.5, 0.5, 0.18, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = DottedHalf;
x1 = FmSynth(Fs, D3,0.5, 0.5, 0.6, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, B2,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, G0,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Eighth;       % Eighth rest
x = FmSynth(Fs, E2,0.5, 0.5, 0.0, 1, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

% Chorus 2
NoteDur = Eighth;
x = FmSynth(Fs, G3,0.5, 0.2, 0.6, 1, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, E3,0.5, 0.2, 0.6, 1, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, C3,0.5, 0.2, 0.6, 1, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, G2,0.5, 0.2, 0.6, 1, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, E2,0.5, 0.2, 0.6, 1, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, G2,0.5, 0.2, 0.6, 1, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, C3,0.5, 0.2, 0.6, 1, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, E3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NoteDur = Eighth;
x = FmSynth(Fs, F3s,0.20, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, D3,0.22, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, A2,0.24, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, F2s,0.26, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;


NoteDur = Eighth;
x = FmSynth(Fs, D2,0.27, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, F2s,0.30, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, A2,0.32, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Eighth;
x = FmSynth(Fs, D3,0.36, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, G3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
x2 = FmSynth(Fs, G3,0.5, 0.2, 0.6, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 +x2;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, G3,0.5, 0.2, 0.4, 0, 0.2, 3, NoteDur);
x2 = FmSynth(Fs, G3,0.5, 0.2, 0.4, 0, 0.2, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 +x2;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, G3,0.5, 0.2, 0.6, 1, 0.5, 3, NoteDur);
x2 = FmSynth(Fs, F3,0.5, 0.2, 0.2, 1, 0.5, 3, NoteDur);
x3 = FmSynth(Fs, A2,0.5, 0.2, 0.2, 1, 0.5, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 +x2 + x3;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, G3,0.5, 0.2, 0.6, 1, 0.5, 3, NoteDur);
x2 = FmSynth(Fs, F3,0.5, 0.2, 0.2, 1, 0.5, 3, NoteDur);
x3 = FmSynth(Fs, A2,0.5, 0.2, 0.2, 1, 0.5, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 +x2 + x3;
Time = Time + NoteDur;

NoteDur = Eighth;
x1 = FmSynth(Fs, E3,0.5, 0.5, 0.6, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, C3,0.5, 0.5, 0.18, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, G1,0.5, 0.5, 0.18, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = DottedHalf;
x1 = FmSynth(Fs, D3,0.5, 0.5, 0.6, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, B2,0.5, 0.5, 0.18, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, G0,0.5, 0.5, 0.18, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Eighth;       % Eighth rest
x = FmSynth(Fs, E2,0.5, 0.5, 0.0, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;



% Chorus 3
NoteDur = Whole;
x1 = FmSynth(Fs, C3,0.5, 0.5, 0.2, 0, 0.5, 3, NoteDur);
x2 = FmSynth(Fs, E3,0.5, 0.5, 0.2, 0, 0.5, 3, NoteDur);
x3 = FmSynth(Fs, G3,0.5, 0.5, 0.2, 0, 0.5, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Eighth;
x1 = FmSynth(Fs, C3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, D3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, F3s,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Eighth;
x1 = FmSynth(Fs, C3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, D3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, F3s,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Eighth;
x1 = FmSynth(Fs, C3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, D3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, F3s,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, C3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, D3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, F3s,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Eighth;
x1 = FmSynth(Fs, C3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, D3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, A3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, C3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, D3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, F3s,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, G3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, D3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, B2,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, G3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, D3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, B2,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, F3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, C3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, A2,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Quarter;
x1 = FmSynth(Fs, F3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, C3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, A2,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Eighth;
x1 = FmSynth(Fs, E3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, C3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, G2,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = DottedHalf;
x1 = FmSynth(Fs, D3,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x2 = FmSynth(Fs, B2,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
x3 = FmSynth(Fs, G2,0.5, 0.5, 0.2, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x1 + x2 + x3;
Time = Time + NoteDur;

NoteDur = Eighth;       % Eighth rest
x = FmSynth(Fs, E2,0.5, 0.5, 0.0, 0, 0.3, 3, NoteDur);
Out(Time : Time+NoteDur-1, 1) = x;
Time = Time + NoteDur;

% 


H = dsp.SpectrumAnalyzer('SampleRate', Fs,  'PlotAsTwoSidedSpectrum', false, 'RBWSource', 'Property', 'RBW', 1, ...
    'PowerUnits', 'dBW','FrequencySpan','Start and stop frequencies', 'StartFrequency', 0, 'StopFrequency', 20000);
step(H,Out);


figure(2);
t = (1 : length(Out))/Fs;
plot(t, Out);


player = audioplayer(Out,44100,16);
play(player);

audiowrite('synth.wav',Out,Fs);

