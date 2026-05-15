%% L2 Link Budget using MATLAB exported calculateLinkBudget function
% L2: Lunar asset / lander / relay -> Earth ground station
% This script uses:
%   res = calculateLinkBudget(spec, sat, tx, rx, lnk)
%
% Important:
%   Frequency  : GHz
%   BitRate    : Mbps
%   Bandwidth  : MHz
%   Tx power   : dBW
%   Altitude for ground station spec: m
%   Altitude for satellite sat: km

clc;
clear;
close all;
%  1. Geometry
%  ========================================================================

% Earth ground station
%The ground station data is imported after selection
%currently use DSN Madrid
g2.Latitude  = 40.4314;      % deg
g2.Longitude = -4.2481;       % deg
g2.Altitude  = 800;       % m

% Lunar asset
% This is a simplified geometry model.
s2.Latitude  = 40.4314;      % deg
s2.Longitude = -4.2481;       % deg
s2.Altitude  = 384400;    % km, approximate Earth-Moon distance


%  2. Transmitter: lunar asset
%  ========================================================================

tx2.TxHPAPower    = 20;       % dBW
tx2.TxHPAOBO      = 6;        % dB, output back-off
tx2.TxFeederLoss  = 1;        % dB
tx2.OtherTxLosses = 1;        % dB
tx2.TxAntennaGain = 35;       % dBi

%  3. Receiver: Earth ground station
%  ========================================================================

% RxGByT is G/T in dB/K.


rx2.RxGByT          = 14;   % dB/K
rx2.RxFeederLoss    = 1;      % dB
rx2.OtherRxLosses   = 1;      % dB
rx2.InterferenceLoss = 2;   % dB

%  4. Link settings
%  ========================================================================

l2.Frequency = 9;           % GHz, X-band baseline
l2.Bandwidth = 4.0;           % MHz
l2.BitRate   = 0.05;           % Mbps

l2.RadomeLoss = 1.0;          % dB
l2.PolarizationMismatch = 45;  % deg
l2.AntennaMispointingLoss = 1.0; % dB

l2.RequiredEbByNo = 6;      % dB
l2.ImplementationLoss = 2.0;  % dB

%  5. Calculate baseline L2 link budget
%  ========================================================================

res2 = calculateLinkBudget(g2, s2, tx2, rx2, l2);

fprintf('\n============================================================\n');
fprintf('                 L2 DOWNLINK BASELINE RESULT\n');
fprintf('============================================================\n');
fprintf('Frequency:                  %.2f GHz\n', l2.Frequency);
fprintf('Bit rate:                   %.3f Mbps\n', l2.BitRate);
fprintf('Bandwidth:                  %.3f MHz\n', l2.Bandwidth);
fprintf('Tx HPA power:               %.2f dBW\n', tx2.TxHPAPower);
fprintf('Tx antenna gain:            %.2f dBi\n', tx2.TxAntennaGain);
fprintf('Ground station G/T:         %.2f dB/K\n', rx2.RxGByT);
fprintf('------------------------------------------------------------\n');
fprintf('Distance:                   %.2f km\n', res2.Distance);
fprintf('Elevation:                  %.2f deg\n', res2.Elevation);
fprintf('Tx EIRP:                    %.2f dBW\n', res2.TxEIRP);
fprintf('Polarization loss:          %.2f dB\n', res2.PolarizationLoss);
fprintf('FSPL:                       %.2f dB\n', res2.FSPL);
fprintf('Received isotropic power:   %.2f dBW\n', res2.ReceivedIsotropicPower);
fprintf('C/N0:                       %.2f dB-Hz\n', res2.CByNo);
fprintf('C/N:                        %.2f dB\n', res2.CByN);
fprintf('Eb/N0:                      %.2f dB\n', res2.ReceivedEbByNo);
fprintf('Required Eb/N0:             %.2f dB\n', l2.RequiredEbByNo);
fprintf('Implementation loss:        %.2f dB\n', l2.ImplementationLoss);
fprintf('Link margin:                %.2f dB\n', res2.Margin);
fprintf('============================================================\n\n');

%% ========================================================================
%  6. Sweep 1: Link margin vs data rate
%  ========================================================================

bitRates_Mbps = logspace(-3, 1, 200);   % 0.001 Mbps to 10 Mbps
margin_vs_rate = zeros(size(bitRates_Mbps));
ebno_vs_rate = zeros(size(bitRates_Mbps));

for i = 1:numel(bitRates_Mbps)
    tempLink = l2;
    tempLink.BitRate = bitRates_Mbps(i);

    tempRes = calculateLinkBudget(g2, s2, tx2, rx2, tempLink);

    margin_vs_rate(i) = tempRes.Margin;
    ebno_vs_rate(i) = tempRes.ReceivedEbByNo;
end

figure;
semilogx(bitRates_Mbps, margin_vs_rate, 'LineWidth', 2);
grid on;
hold on;
yline(3, '--', 'Nominal margin = 3 dB', 'LineWidth', 1.5);
yline(0, '--', 'Link closure = 0 dB', 'LineWidth', 1.5);
xlabel('Bit Rate [Mbps]');
ylabel('Link Margin [dB]');
title('L2 Downlink Margin vs Data Rate');

%% ========================================================================
%  7. Sweep 2: Link margin vs transmit power
%  ========================================================================

txPower_W = linspace(1, 100, 200);
txPower_dBW = 10*log10(txPower_W);

margin_vs_power = zeros(size(txPower_W));

for i = 1:numel(txPower_W)
    tempTx = tx2;
    tempTx.TxHPAPower = txPower_dBW(i);

    tempRes = calculateLinkBudget(g2, s2, tempTx, rx2, l2);

    margin_vs_power(i) = tempRes.Margin;
end

figure;
plot(txPower_W, margin_vs_power, 'LineWidth', 2);
grid on;
hold on;
yline(3, '--', 'Nominal margin = 3 dB', 'LineWidth', 1.5);
yline(0, '--', 'Link closure = 0 dB', 'LineWidth', 1.5);
xlabel('Transmit Power [W]');
ylabel('Link Margin [dB]');
title('L2 Downlink Margin vs Transmit Power');

%% ========================================================================
%  8. Sweep 3: Link margin vs Tx antenna gain
%  ========================================================================

txGain_dBi = linspace(0, 40, 200);
margin_vs_txgain = zeros(size(txGain_dBi));

for i = 1:numel(txGain_dBi)
    tempTx = tx2;
    tempTx.TxAntennaGain = txGain_dBi(i);

    tempRes = calculateLinkBudget(g2, s2, tempTx, rx2, l2);

    margin_vs_txgain(i) = tempRes.Margin;
end

figure;
plot(txGain_dBi, margin_vs_txgain, 'LineWidth', 2);
grid on;
hold on;
yline(3, '--', 'Nominal margin = 3 dB', 'LineWidth', 1.5);
yline(0, '--', 'Link closure = 0 dB', 'LineWidth', 1.5);
xlabel('Tx Antenna Gain [dBi]');
ylabel('Link Margin [dB]');
title('L2 Downlink Margin vs Tx Antenna Gain');

%% ========================================================================
%  9. Sweep 4: Link margin vs frequency
%  ========================================================================


freq_GHz = linspace(1, 12, 300);
margin_vs_freq = zeros(size(freq_GHz));
fspl_vs_freq = zeros(size(freq_GHz));

for i = 1:numel(freq_GHz)
    tempLink = l2;
    tempLink.Frequency = freq_GHz(i);

    tempRes = calculateLinkBudget(g2, s2, tx2, rx2, tempLink);

    margin_vs_freq(i) = tempRes.Margin;
    fspl_vs_freq(i) = tempRes.FSPL;
end

figure;
plot(freq_GHz, fspl_vs_freq, 'LineWidth', 2);
grid on;
hold on;
xline(2.2, '--', 'S-band approx.', 'LineWidth', 1.5);
xline(8.4, '--', 'X-band approx.', 'LineWidth', 1.5);
xlabel('Frequency [GHz]');
ylabel('FSPL [dB]');
title('Free-Space Path Loss vs Frequency for L2');

figure;
plot(freq_GHz, margin_vs_freq, 'LineWidth', 2);
grid on;
hold on;
yline(3, '--', 'Nominal margin = 3 dB', 'LineWidth', 1.5);
yline(0, '--', 'Link closure = 0 dB', 'LineWidth', 1.5);
xline(2.2, '--', 'S-band approx.', 'LineWidth', 1.5);
xline(8.4, '--', 'X-band approx.', 'LineWidth', 1.5);
xlabel('Frequency [GHz]');
ylabel('Link Margin [dB]');
title('L2 Downlink Margin vs Frequency');

%% ========================================================================
%  10. Operating mode comparison
%  ========================================================================

modeNames = ["Safe mode", "Nominal TTC", "High-rate 1 Mbps", "High-rate 5 Mbps"];
modeRates_Mbps = [0.001, 0.050, 1.0, 5.0];

fprintf('\n============================================================\n');
fprintf('                 L2 OPERATING MODE COMPARISON\n');
fprintf('============================================================\n');

for i = 1:numel(modeRates_Mbps)
    tempLink = l2;
    tempLink.BitRate = modeRates_Mbps(i);

    tempRes = calculateLinkBudget(g2, s2, tx2, rx2, tempLink);

    fprintf('%-18s | Rb = %8.4f Mbps | Eb/N0 = %8.2f dB | Margin = %8.2f dB\n', ...
        modeNames(i), tempLink.BitRate, tempRes.ReceivedEbByNo, tempRes.Margin);
end

fprintf('============================================================\n\n');
%% link budget function provided by matlab
%do not touch
function res = calculateLinkBudget(spec,sat,tx,rx,lnk,varargin)
assignin("base","struct1",spec);
assignin("base","struct2",sat);
assignin("base","struct3",tx);
assignin("base","struct4",rx);
assignin("base","struct5",lnk);
resultProperty = [];
resultVariable = [];
if nargin > 5
    resultVariable = varargin{1};
end
if nargin == 8
    resultProperty = varargin{2};
    resultValue = varargin{3};
end
params = {"Distance";"Elevation";"TxEIRP";"PolarizationLoss";...
    "FSPL";"ReceivedIsotropicPower";"CByNo";"CByN";...
    "ReceivedEbByNo";"Margin"};
eqns = {"satcom.internal.linkbudgetApp.computeDistance(struct1.Latitude, struct1.Longitude, struct1.Altitude, struct2.Latitude, struct2.Longitude, struct2.Altitude*1e3)";...
    "satcom.internal.linkbudgetApp.computeElevation(struct1.Latitude, struct1.Longitude, struct1.Altitude, struct2.Latitude, struct2.Longitude, struct2.Altitude*1e3)";...
    "struct3.TxHPAPower - struct3.TxHPAOBO - struct3.TxFeederLoss - struct3.OtherTxLosses + struct3.TxAntennaGain - struct5.RadomeLoss";...
    "20 * abs(log10(cosd(struct5.PolarizationMismatch)))";...
    "fspl(temp.Distance * 1e3, physconst('LightSpeed') ./ (struct5.Frequency*1e9))";...
    "temp.TxEIRP - temp.PolarizationLoss - temp.FSPL - struct4.InterferenceLoss - struct5.AntennaMispointingLoss";...
    "temp.ReceivedIsotropicPower + struct4.RxGByT - 10*log10(physconst('Boltzmann')) - struct4.RxFeederLoss - struct4.OtherRxLosses";...
    "temp.CByNo - 10*log10(struct5.Bandwidth) - 60";...
    "temp.CByNo - 10*log10(struct5.BitRate) - 60";...
    "temp.ReceivedEbByNo - struct5.RequiredEbByNo - struct5.ImplementationLoss"};
if nargin == 7
    vectorSpecValue = varargin{2};
    eqns{1} = mat2str(vectorSpecValue);
end
for ii = 1:length(params)
    varname = strcat("temp.",params{ii});
    if any(strcmp(resultProperty,params{ii}))
        evalin("base",sprintf("%s = %f;",varname,resultValue(strcmp(resultProperty,params{ii}))))
    else
        evalin("base",sprintf("%s = %s;",varname,eqns{ii}))
    end
    if strcmp(resultVariable,params{ii}) && ~isempty(resultVariable)
        break;
    end
end
res = evalin("base","temp");
evalin("base","clear struct1 struct2 struct3 struct4 struct5 temp");
end

