function [Yfft, f] = spectrum_analyzer(signal, Fs)

fourier_transform = fft(signal);
L = length(signal);

P2 = abs(fourier_transform/L);
P1 = P2(1:floor(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs/L*(0:(L/2));
Yfft = P1;

end