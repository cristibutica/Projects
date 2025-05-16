function GUI_semnalizare

fig_semnalizare = uifigure('Name', 'Semnalizare de adresă', ...
    'units', 'normalized', ...
    'position', [0.1 0.1 0.6 0.7]);

% figură pentru reprezentare semnal în timp
ax_signal = axes('Parent', fig_semnalizare, 'Position', [0.55, 0.6, 0.4, 0.3]);  
xlabel(ax_signal, 'Timp (s)');
ylabel(ax_signal, 'Amplitudine [V]');
title(ax_signal, 'Vizualizare semnal in timp');
grid(ax_signal, 'on');

% figură pentru reprezentare semnal în frecvență
ax_spectrum = axes('Parent', fig_semnalizare, 'Position', [0.55, 0.2, 0.4, 0.3]);  
xlabel(ax_spectrum, 'Frecvență (Hz)');
ylabel(ax_spectrum, 'Amplitudine [V]');
title(ax_spectrum, 'Analizor Spectral');
grid(ax_spectrum, 'on');

% inițializarea cheilor (cifrelor) într-un dicționar
keyDigits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0" ,"#"];

% pentru fiecare cifră vom avea 2 frecvențe fi și fs
valueDigits = {...
    {697, 1209}, ... % 1
    {697, 1339}, ... % 2
    {697, 1477}, ... % 3
    {770, 1209}, ... % 4
    {770, 1339}, ... % 5
    {770, 1477}, ... % 6
    {852, 1209}, ... % 7
    {852, 1339}, ... % 8
    {852, 1477}, ... % 9
    {941, 1209}, ... % *
    {941, 1339}, ... % 0
    {941, 1477}, ... % #
};

% construim dicționarul
digitsDict = dictionary(keyDigits, valueDigits);

% meniu drop-down pentru selectare semnalizare
dd = uidropdown(fig_semnalizare, ...
    'Items', {'Semnalizare prin impuls', 'Semnalizare prin tonuri DTMF'}, ...
    'Position', [20, 20, 250, 30]);

% etichetă pentru câmpul de introducere a numărului de telefon
uilabel(fig_semnalizare, ...
    "Text", "Număr de telefon", ...
    "Position", [50 500 200 40], ... 
    "FontSize", 12);

% câmp pentru introducerea numărului de telefon
afisaj = uieditfield(fig_semnalizare, 'text', ...
    'Editable', 'on', ...
    'Position', [50 470 200 40], ...
    'FontSize', 20, ...
    'ValueChangingFcn', @(src,event) valideaza_input_dinamic(src,event));

% etichetă pentru câmpul de introducere a nivelului de zgomot pentru
% semnalul generat
uilabel(fig_semnalizare, ...
    "Text", "Puterea zgomotului [dBW]", ...
    "Position", [50 420 200 40], ... 
    "FontSize", 12);

% câmp pentru introducerea nivelului de zgomot
pZgomotField = uieditfield(fig_semnalizare, 'numeric', ...
    'Editable', 'on', ...
    'Value',-100,...
    'Position', [50 390 200 40], ...
    'FontSize', 20);

% etichetă pentru câmpul de calculare a puterii semnalului
uilabel(fig_semnalizare, ...
    "Text", "Puterea semnalului [dBW]", ...
    "Position", [50 360 200 40], ... 
    "FontSize", 12);

% câmpul de calculare a puterii semnalului
pSemnalField = uieditfield(fig_semnalizare, 'text', ...
    'Editable', 'off', ...
    'Position', [50 330 200 40], ...
    'FontSize', 20);

% etichetă pentru câmpul de calculare a SNR-ului
uilabel(fig_semnalizare, ...
    "Text", "SNR [dB]", ...
    "Position", [50 300 200 40], ... 
    "FontSize", 12);

% câmpul de calculare a SNR-ului
snr = uieditfield(fig_semnalizare, 'text', ...
    'Editable', 'off', ...
    'Position', [50 270 200 40], ...
    'FontSize', 20);

% etichetă pentru câmpul de selectare a filtrului
uilabel(fig_semnalizare, ...
    "Text", "Filtru", ...
    "Position", [50 220 200 40], ... 
    "FontSize", 12);

% câmpul de selectare a filtrului
filters = uidropdown(fig_semnalizare, ...
    'Items', {'Filtru trece jos', 'Filtru trece sus', 'Filtru trece bandă'}, ...
    'Position', [20, 200, 250, 30]);

% buton filtrare semnal
bFiltrare = uicontrol(fig_semnalizare, ...
    'Style', 'pushbutton', ...
    'Enable', 'off', ...
    'String', 'Filtrează', ...
    'FontSize', 12, ...
    'Position', [50 150 100 50], ...
    'Callback', @(src, event) filtrareSemnal(src, ax_signal,ax_spectrum));  

% buton generare semnal
bGenerare = uicontrol(fig_semnalizare, ...
    'Style', 'pushbutton', ...
    'Enable', 'off', ...
    'String', 'Generare', ...
    'FontSize', 12, ...
    'Position', [50 50 100 50], ...
    'Callback', @(src, event) updatePlot(src, ax_signal,ax_spectrum));  

% structură în care salvez toate componentele de care am nevoie, butoane...
guidata(fig_semnalizare, struct('bGenerare', bGenerare,'meniuSemnalizare',dd,'campNumar',afisaj, ...
    'digitsDict',digitsDict,'pZgomot',pZgomotField,'pSemnal',pSemnalField,'snr',snr,'figSemnalizare', ...
    fig_semnalizare,'bFiltrare',bFiltrare,'filters',filters));

end


% funcția în care validez numărul de telefon introdus în timp real
function valideaza_input_dinamic(src, event)
    components = guidata(src); % preiau componente din structură
    val = event.Value; % preiau continutul in curs de introducere, deci și caracterul tastat.
    % cu src.Value ar fi trebuit să apăs enter pentru a prelua acea valoare

    % dacă acest câmp este gol, nu pot genera semnalizarea încă
    if ~isempty(event.Value)
        components.bGenerare.Enable = 'on';
    else
        components.bGenerare.Enable = 'off';
    end

    if isequal(components.meniuSemnalizare.Value, 'Semnalizare prin impuls')
        val_filtrat = regexprep(val, '[^0-9]', '');  % doar cifre dacă e semnalizare prin impuls
    else
        val_filtrat = regexprep(val, '[^0-9#*]', '');  % doar cifre, # și * pt ton DTMF
    end
 
    src.Value = val_filtrat; % filtrez valoarea câmpului
end


% funcția pentru filtrarea semnalului generat
function filtrareSemnal(src, ax_signal,ax_spectrum)
    components = guidata(src); % preiau componentele din structură

    switch components.meniuSemnalizare.Value % logică diferită în funcție de tipul de semnalizare

        case 'Semnalizare prin impuls'

            semnal = getappdata(components.figSemnalizare,'semnalImpuls'); % preiau semnalul din appdata
            timp = getappdata(components.figSemnalizare,'timpImpuls'); % preiau timpul din appdata
            fe = getappdata(components.figSemnalizare,'feImpuls'); % preiau fe din appdata

            switch components.filters.Value % logică diferită pentru fiecare filtrare

                case 'Filtru trece jos'
                    f_pass = 100; % frecvența de tăiere;
                    [semnal_filtrat, digital_filter_obj] = lowpass(semnal, f_pass, fe, 'Steepness', 0.99);

                case 'Filtru trece sus'
                    f_pass = 10; % frecvența de tăiere;
                    [semnal_filtrat, digital_filter_obj] = highpass(semnal, f_pass, fe, 'Steepness', 0.99);

                case 'Filtru trece bandă'
                    f_pass = [10 100]; % frecvențele de tăiere low și high;
                    [semnal_filtrat, digital_filter_obj] = bandpass(semnal, f_pass, fe, 'Steepness', 0.99);
            end

            % dacă vreau să generez alt ton, dar deja a fost generat unul, trebuie
            % să șterg axele întâi pentru a nu suprapune plot-urile unul
            % peste altul
            cla(ax_signal);
            cla(ax_spectrum);
        
            % dacă nu am hold on, plot-ul de mai jos va recrea de fapt axa ca și
            % cum ar fi una nouă, deci aici salvez xlabel, ylabel, etc.
            hold(ax_signal, 'on');  
            hold(ax_spectrum, 'on');

            % plot în timp și spectru
            plot(ax_signal, timp, semnal_filtrat, 'b', 'LineWidth', 1.5);
        
            [Yfft, f] = spectrum_analyzer(semnal_filtrat, fe);
            plot(ax_spectrum, f, Yfft, 'r', 'LineWidth', 1.5);
                               
            % revenire la comportament inițial pentru a nu suprapune
            % plot-urile
            hold(ax_signal, 'off');  
            hold(ax_spectrum, 'off');
            fvtool(digital_filter_obj); % caracteristica filtrului

        case 'Semnalizare prin tonuri DTMF'
            semnal = getappdata(components.figSemnalizare,'semnalDTMF'); % preiau semnalul din appdata
            timp = getappdata(components.figSemnalizare,'timpDTMF'); % preiau timpul din appdata
            fe = getappdata(components.figSemnalizare,'feDTMF'); % preiau fe din appdata

            switch components.filters.Value

                case 'Filtru trece jos'
                    f_pass = 1500; % frecvența de tăiere;
                    [semnal_filtrat, digital_filter_obj] = lowpass(semnal, f_pass, fe, 'Steepness', 0.99);

                case 'Filtru trece sus'
                    disp('aici')
                    f_pass = 550; % frecvența de tăiere;
                    [semnal_filtrat, digital_filter_obj] = highpass(semnal, f_pass, fe, 'Steepness', 0.99);

                case 'Filtru trece bandă'
                    disp('aici')
                    f_pass = [550 1900]; % frecvențele de tăiere low și high;
                    [semnal_filtrat, digital_filter_obj] = bandpass(semnal, f_pass, fe, 'Steepness', 0.99);
            end

            % dacă vreau să generez alt ton, dar deja a fost generat unul, trebuie
            % să șterg axele întâi pentru a nu suprapune plot-urile unul
            % peste altul
            cla(ax_signal);
            cla(ax_spectrum);
        
            % dacă nu am hold on, plot-ul de mai jos va recrea de fapt axa ca și
            % cum ar fi una nouă, deci aici salvez xlabel, ylabel, etc.
            hold(ax_signal, 'on');  
            hold(ax_spectrum, 'on');

            % plot in timp si spectru
            plot(ax_signal, timp, semnal_filtrat, 'b', 'LineWidth', 1.5);
        
            [Yfft, f] = spectrum_analyzer(semnal_filtrat, fe);
            plot(ax_spectrum, f, Yfft, 'r', 'LineWidth', 1.5);
                               
            % revenire la comportament inițial pentru a nu suprapune
            % plot-urile
            hold(ax_signal, 'off');  
            hold(ax_spectrum, 'off');
            fvtool(digital_filter_obj); % caracteristica filtrului
    end
          
end


% funcția în care generez semnalizarea aleasă din meniul drop-down
function updatePlot(src, ax_signal,ax_spectrum)
    components = guidata(src); % preiau componente din structură

    vector_digits = double(components.campNumar.Value); % preiau textul din câmpul pt introducerea
    % numărului și îl transform într-un vector, în care fiecare element
    % devine codul ascii al caracterului din text

    pZgomot = components.pZgomot.Value; % puterea zgomotului în dBW
    switch components.meniuSemnalizare.Value % generare în funcție de semnalizarea aleasă
        case 'Semnalizare prin impuls'
            vector_digits = vector_digits - double('0'); % scad '0' (48d sau 30h) pentru a obține cifrele corecte
            fe=1000; % frecvența de eșantionare
            TM=0.033; % timp make
            TB=0.066; % timp break
            TI=0.4; % timp interdigit
            SM = zeros(1,floor(TM*fe)); %o perioada semnal make
            SB= ones(1,floor(TB*fe));% o perioada semnal break
            SI=zeros(1,floor(TI*fe));%o perioada semnal interdigit
            sBM=[SB SM]; % o perioada break+make
            sCapat = [SB SI];% semnal capat
            
            semnal=SI; % incepem cu perioada semnal interdigit
            for i=1:length(vector_digits)
                digit=vector_digits(i);
            
                if digit ==0
                    digit=10; % 10 impulsuri pt cifra 0
                end
            
                semnal = [semnal repmat(sBM, 1, digit-1)]; % concatenez la semnal pulsurile corespunzatoare tuturor 
                % cifrelor de la 0-9. Vom avea la inceput interdigit + length(vector_digits)*(break+make) perioade
                semnal = [semnal sCapat]; % secventa de la capat
            end
            timp = (0:length(semnal)-1)/fe; % calculăm timpul total al semnalizării
           
            signal_power_measured = rms(semnal)^2;% puterea efectivă a semnalului generat
            components.pSemnal.Value = num2str(10*log10(signal_power_measured)); % valoarea puterii semnalului
            % în câmpul corespunzător

            noise = wgn(1, length(semnal), pZgomot);% definim vector de zgomot gaussian
           
            components.snr.Value = num2str(10*log10(signal_power_measured) - pZgomot); % SNR = Psemnal - Pzgomot
            semnal_cu_zgomot = semnal + noise; % adăugam zgomot gaussian peste semnal

            % dacă vreau să generez alt ton, dar deja a fost generat unul, trebuie
            % să șterg axele întâi pentru a nu suprapune plot-urile unul
            % peste altul
            cla(ax_signal);
            cla(ax_spectrum);
        
            % dacă nu am hold on, plot-ul de mai jos va recrea de fapt axa ca și
            % cum ar fi una nouă, deci aici salvez xlabel, ylabel, etc.
            hold(ax_signal, 'on');  
            hold(ax_spectrum, 'on');

            % plot in timp si spectru
            plot(ax_signal, timp, semnal_cu_zgomot, 'b', 'LineWidth', 1.5);
        
            [Yfft, f] = spectrum_analyzer(semnal_cu_zgomot, fe);
            plot(ax_spectrum, f, Yfft, 'r', 'LineWidth', 1.5);
            
            setappdata(components.figSemnalizare, 'semnalImpuls', semnal_cu_zgomot);  % salvez semnalul în appdata
            setappdata(components.figSemnalizare, 'timpImpuls', timp);  % salvez timpul în appdata
            setappdata(components.figSemnalizare, 'feImpuls', fe);  % salvez fe în appdata
            
            components.bFiltrare.Enable = 'on'; % după generare se poate filtra

            % revenire la comportament inițial pentru a nu suprapune
            % plot-urile
            hold(ax_signal, 'off');  
            hold(ax_spectrum, 'off');


        case 'Semnalizare prin tonuri DTMF'
            digitsDict = components.digitsDict; % preluăm dicționarul din structură
            fe = 6000; % frecv eșantionare
            A1 = 0.2; % amplitudine fi
            A2 = 0.3; % amplitudinde fs
            Tton = 0.09; % perioadă ton
            Tpauza = 0.01; % perioadă pauza
            
            spause = zeros(1, floor(Tpauza*fe)); % vector pt semnal de pauză
            t =  0 :1/fe : Tton - 1/fe; % timpul în care tonul e ON
            
            signal_all = 0;

            % dacă vreau să generez alt ton, dar deja a fost generat unul, trebuie
            % să șterg axele întâi pentru a nu suprapune plot-urile unul
            % peste altul
            cla(ax_signal);
            cla(ax_spectrum);
            
            % parcurg vectorul de cifre introduse
            for i=1:length(vector_digits)
 
                value = digitsDict(char(vector_digits(i))); % preiau codurile ascii ca și caractere 
                % pt a putea accesa valorile din dicționar
               
                frecvente = value{1}; % cell array de valori
                fi = frecvente{1}; % frecv inferioară pe poz 1 din cell array
                fs = frecvente{2}; % frecv superioară pe poz 2 din cell array
                dtmf_ton = A1*sin(2*pi*fi*t) + A2*sin(2*pi*fs*t); % 1 ton dtmf
                signal = [dtmf_ton spause]; % concatenez cu semnal de pauză

                noise = wgn(1, length(signal), pZgomot);% definim vector de zgomot gaussian pt fiecare ton dtmf
                semnal_cu_zg = signal + noise; % adaug zgomot peste fiecare ton in parte
                signal_all = [signal_all semnal_cu_zg]; % concatenez toate tonurile dtmf
            
                % dacă nu am hold on, plot-ul de mai jos va recrea de fapt axa ca și
                % cum ar fi una nouă, deci aici salvez xlabel, ylabel, etc.
                hold(ax_signal, 'on');  
                hold(ax_spectrum, 'on');
        
                sound(semnal_cu_zg,fe) % trimit la placa de sunet
                pause(Tton+ Tpauza); % delay intre tonuri
            end
            
            time=(0:length(signal_all) - 1/fe)/fe; % timpul total
   
            signal_power_measured = rms(signal_all)^2;% puterea efectiva a semnalului generat
            components.pSemnal.Value = num2str(10*log10(signal_power_measured)); % valoarea puterii semnalului
            % în câmpul corespunzător
           
            components.snr.Value = num2str(10*log10(signal_power_measured) - pZgomot); % SNR = Psemnal - Pzgomot
            
            % plot în timp si spectru
            plot(ax_signal, time, signal_all, 'b', 'LineWidth', 1.5);

            [Yfft, f] = spectrum_analyzer(signal_all, fe);
            plot(ax_spectrum, f, Yfft, 'r', 'LineWidth', 1.5);
            
            setappdata(components.figSemnalizare, 'semnalDTMF', signal_all);  % salvez semnalul în appdata
            setappdata(components.figSemnalizare, 'timpDTMF', time);  % salvez timpul în appdata
            setappdata(components.figSemnalizare, 'feDTMF', fe);  % salvez fe în appdata

            components.bFiltrare.Enable = 'on'; % după generare se poate filtra

            % revenire la comportament inițial pentru a nu suprapune
            % plot-urile
            hold(ax_signal, 'off');  
            hold(ax_spectrum, 'off');
    end
end

