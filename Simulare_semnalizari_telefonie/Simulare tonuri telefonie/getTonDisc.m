function [ton_de_disc, t] = getTonDisc(Te)

t = 0:Te:10; % durata tonului
ton_de_disc = 0.5*sin(2*pi*400*t); %  tonul de amplitudine 0.5V si frecvență 400Hz

end

