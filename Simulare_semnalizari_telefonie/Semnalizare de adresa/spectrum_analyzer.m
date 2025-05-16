function [Yfft, f] = spectrum_analyzer(signal, Fs)

fourier_transform = fft(signal); % aplicăm transformata fourier rapidă peste semnal

L = length(signal); % lungimea semnalului în eșantioane

P2 = abs(fourier_transform/L); % normalizare și păstrarea amplitudinii din valoarea complexă
P1 = P2(1:floor(L/2)+1); % convertire din spectru bilateral în unilateral
P1(2:end-1) = 2*P1(2:end-1); % înmulțire cu 2 componente pt conservarea energiei totale

f = Fs/L*(0:(L/2)); % vector de frecvențe
Yfft = P1; % amplitudinea normalizată

end