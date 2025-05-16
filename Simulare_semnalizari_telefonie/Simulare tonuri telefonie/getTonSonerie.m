function [sonerie_rep] = getTonSonerie(tson,tpause,Nrep,Fs_field)

[y, Fs] = audioread('telephone-ring-02.wav');
y = y(:, 1); % păstrăm doar primul canal

nson = tson * Fs_field; % nr esantionane pt sonerie on
npause = tpause * Fs_field; % nr esantioane pt sonerie off

sonerie = y(745 : 745 + nson - 1); % incep de la esantionul 745, doar de acolo am semnal

% creare coloană pauză (zero-uri)
pauza = zeros(npause, 1);

% concatenare verticală semnal + pauză
sonerie1 = [sonerie; pauza];

% repetare semnal Nrep ori
sonerie_rep = repmat(sonerie1, Nrep, 1);

end

