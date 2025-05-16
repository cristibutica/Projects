function [signal_rep,time_full] = getTonOcupat(Te,T_ON)

t_on = 0 : Te : T_ON - Te; % vector timp pt ton si toff, sunt de aceeasi lungime

signal_on = 0.5*sin(2*pi*400*t_on); % generez semnalul on
signal_off = zeros(1, length(t_on)); % generez semnalul off

signal = [signal_on signal_off]; % concatenez cele 2 semnale

Numar_rep = 10; % de cate ori sa se repete semnalele on si off

signal_rep = signal;
for i=1:Numar_rep - 1
    signal_rep = [signal_rep signal]; % tot timpul concatenez vectorul rezultat la un alt vector, 
    % deci va creste dimensiunea la fiecare iteratie
end

time_full = (0:length(signal_rep)- Te); % recalculez vectorul de timp pentru intreg semnalul

end

