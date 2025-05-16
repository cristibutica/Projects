function GUI_tonuri

T_ON_ocupat = 0.5; % per ton ocupat on+off

T_ON_revers = 1; % per ton revers on
T_OFF_revers = 4; % per ton revers off

tson_sonerie = 1; % per în care semnalul suna
tpause_sonerie = 6; % per în care semnalul nu suna

Nrep_sonerie = 10; % numărul de repetiții pt sonerie

sine_tone = uifigure('Name', 'Tonuri', ...
    'units', 'normalized', ...
    'position', [0.1 0.1 0.6 0.7]);

% figură pentru reprezentare semnal în timp
ax_signal = axes('Parent', sine_tone, 'Position', [0.1, 0.6, 0.8, 0.3]);  
xlabel(ax_signal, 'Timp (s)');
ylabel(ax_signal, 'Amplitudine [V]');
title(ax_signal, 'Vizualizare semnal in timp');
grid(ax_signal, 'on');

% figură pentru reprezentare semnal în frecvență
ax_spectrum = axes('Parent', sine_tone, 'Position', [0.1, 0.2, 0.8, 0.3]);  
xlabel(ax_spectrum, 'Frecvență (Hz)');
ylabel(ax_spectrum, 'Amplitudine');
title(ax_spectrum, 'Analizor Spectral');
grid(ax_spectrum, 'on');

% inițializarea tonurilor într-un dicționar
keyTones = ["Ton de disc", "Ton de ocupat", "Ton revers apel", "Ton de sonerie"];
[ton_disc, t_disc] = getTonDisc(1/8000); % se trimite perioada de esantionare initiala
[ton_ocupat, t_ocupat] = getTonOcupat(1/8000, T_ON_ocupat); % t_on ocupat pt ca trb sa fie simetric t_on cu t_off
[ton_revers, t_revers] = getTonReversApel(1/8000, T_ON_revers, T_OFF_revers);
[sonerie_rep] = getTonSonerie(tson_sonerie, tpause_sonerie, Nrep_sonerie, 48000); % 48kHz f_es initial

t_sonerie = (0:length(sonerie_rep)-1); % vector timp pentru tonul de sonerie

% pentru fiecare cheie vom avea tonul si timpul
valueTones = {...
    {ton_disc, t_disc}, ...
    {ton_ocupat, t_ocupat}, ...
    {ton_revers, t_revers}, ...
    {sonerie_rep,t_sonerie} ...
};

% construim dicționarul
d = dictionary(keyTones, valueTones);

% etichetă pentru câmpul de rată de eșantionare
uilabel(sine_tone, ...
    "Text", "Rată de eșantionare (Hz)", ...
    "Position", [300 60 150 22], ...  
    "FontSize", 12);

% edit field pentru rată de eșantionare
sampleRate = uieditfield(sine_tone, "numeric", ...
    "Position", [300 10 100 50], ...
    "Limits", [1000 16000], ...
    "Value", 8000, ...
    "ValueChangedFcn", @(src,event) changeOnOffPeriodAndSampleRate(src, d, Nrep_sonerie)); 

% etichetă pentru câmpul de perioadă ON
uilabel(sine_tone, ...
    "Text", "Perioada ON (s)", ...
    "Position", [550 60 150 22], ...  
    "FontSize", 12);

% edit field pentru perioadă ON
TonField = uieditfield(sine_tone, "numeric", ...
    "Position", [550 10 100 50], ...
    "Limits", [0.5 15], ...
    "Value", 1, ...
    "ValueChangedFcn", @(src,event) changeOnOffPeriodAndSampleRate(src,d,Nrep_sonerie)); 

% etichetă pentru câmpul de perioadă OFF
uilabel(sine_tone, ...
    "Text", "Perioada OFF (s)", ...
    "Position", [650 60 150 22], ...  
    "FontSize", 12);

% edit field pentru perioadă OFF
ToffField = uieditfield(sine_tone, "numeric", ...
    "Position", [650 10 100 50], ...
    "Limits", [0.5 15], ...
    "Value", 1, ...
    "ValueChangedFcn", @(src,event) changeOnOffPeriodAndSampleRate(src,d,Nrep_sonerie)); 

% etichetă pentru câmpul interval de timp
uilabel(sine_tone, ...
    "Text", "Interval de timp [s]", ...
    "Position", [450 60 150 22], ... 
    "FontSize", 12);

% edit field needitabil pentru câmpul interval de timp
timeInterval = uieditfield(sine_tone, "text", ...
    "Position", [450 10 100 50], ...
    "Enable","off"); 

% buton start-stop semnal
bStartStop = uicontrol(sine_tone, ...
    'Style', 'pushbutton', ...
    'Enable', 'off', ...
    'String', 'Start', ...
    'FontSize', 12, ...
    'Position', [175 50 100 50], ...
    'Callback', @(src, event) startStop(src, ax_signal,ax_spectrum,d,sampleRate.Value,sine_tone));

% buton generare semnal
bGenerare = uicontrol(sine_tone, ...
    'Style', 'pushbutton', ...
    'Enable', 'on', ...
    'String', 'Generare', ...
    'FontSize', 12, ...
    'Position', [50 50 100 50], ...
    'Callback', @(src, event) updatePlot(src, ax_signal,ax_spectrum,d,sampleRate.Value,bStartStop,sine_tone, ...
    timeInterval));  

% meniu drop-down pentru selectare tonuri
dd = uidropdown(sine_tone, ...
    "Items", keyTones, ...
    "Position", [20, 20, 150, 30], ...
    "ValueChangedFcn", @(src,event) setTone(src, d, bGenerare,bStartStop,sampleRate,Nrep_sonerie));

% structură în care salvez toate componentele de care am nevoie, butoane...
guidata(sine_tone, struct('bStartStop', bStartStop, 'bGenerare', bGenerare,'sampleRate',sampleRate,'tonField', ...
    TonField,'toffField',ToffField, 'toneMenu',dd));

end


% functie pentru schimbarea perioadelor ON/OFF ale tonurilor și modificarea
% ratei de eșantionare
function changeOnOffPeriodAndSampleRate(src, d, Nrep_sonerie)

    % preiau toate componentele salvate anterior pentru ușurința
    % implementării
    components = guidata(src);

    % reapelez funcțiile pt determinarea tonurilor, cu parametri din
    % edit_field-uri
    [semnal_sonerie] = getTonSonerie(components.tonField.Value, components.toffField.Value, Nrep_sonerie, ...
        components.sampleRate.Value);
    t_sonerie = (0:length(semnal_sonerie)-1); % recalculez vectorul de timp pt sonerie
    
    d("Ton de sonerie") = {{semnal_sonerie, t_sonerie}}; 

    [ton_disc, t_disc] = getTonDisc(1/components.sampleRate.Value);
    d("Ton de disc") = { {ton_disc, t_disc} };

    [ton_ocupat, t_ocupat] = getTonOcupat(1/components.sampleRate.Value, components.tonField.Value);
    d("Ton de ocupat") = { {ton_ocupat, t_ocupat} };

    [ton_revers, t_revers] = getTonReversApel(1/components.sampleRate.Value, components.tonField.Value, ...
        components.toffField.Value);
    d("Ton revers apel") = { {ton_revers, t_revers} };

    % actualizez tonul ales în UserData-ul butoanelor, voi avea nevoie mai
    % jos în cod
    components.bStartStop.UserData = d(components.toneMenu.Value);
    disp(components.toneMenu.Value);
    components.bGenerare.UserData = d(components.toneMenu.Value);

    % dacă am schimbat perioadele ON/OFF sau rata de eșantionare, trebuie să generez din nou tonul,
    % abia după aceea pot folosi butonul start/stop
    components.bStartStop.Enable = 'off';
    components.bGenerare.Enable = 'on';
end

% funcție pentru setarea tonului curent din meniul drop-down, aceasta se
% execută de fiecare dată când aleg alt ton din meniu
function setTone(src, d, bGenerare,bStartStop,sampleRate,Nrep_sonerie)
    
    components = guidata(src);
    % salvez tonul selectat în UserData-ul butoanelor start/stop și
    % generare
    tonSelectat = src.Value;
    bGenerare.UserData = d(tonSelectat);
    bStartStop.UserData = d(tonSelectat);
    % după ce am selectat tonul, trebuie întâi să îl generez
    bGenerare.Enable = 'on';
    bStartStop.Enable = 'off';
    % intervale și valori implicite diferite pentru ton de sonerie și
    % celelate tonuri
    if tonSelectat == "Ton de sonerie"
        sampleRate.Limits = [1000 96000]; % pot balea frecvența de eșantionare în acest interval
        sampleRate.Value = 48000;
        % trebuie actualizat tonul de sonerie în dicționar pentru că am modificat
        % frecvența de eșantionare, ea fiind inițial de 8kHz
        [semnal_sonerie] = getTonSonerie(components.tonField.Value, components.toffField.Value, Nrep_sonerie, ...
        components.sampleRate.Value);
        t_sonerie = (0:length(semnal_sonerie)-1); % recalculez vectorul de timp pentru sonerie
    
        d("Ton de sonerie") = {{semnal_sonerie, t_sonerie}}; 

    else
        % pentru celelalte tonuri am alt interval de frecvență și altă
        % valoare implicită
        sampleRate.Limits = [1000 16000];
        sampleRate.Value = 8000;
        
    end
end


% funcție pentru generarea tonurilor, aceasta se apelează de fiecare dată
% când apăs pe butonul de generare 
function updatePlot(src, ax_signal, ax_spectrum, d,Fs,bStartStop,sine_tone,timeInterval)

    persistent player; % dacă nu îl făceam persistent, 
    % după ce se apela funcția obiectul player se distrugea și nu se mai auzea nimic

    % verificăm dacă UserData-ul e gol
    if isempty(src.UserData)
        data = d("Ton de disc"); % când se porneste plot-ul pt prima dată nu am
        % nimic în userdata, deci inițializez cu ton de disc
    else
        data = src.UserData;
    end

    % preiau toate componentele din structură
    components = guidata(src);
    
    % am generat semnalul, înseamnă că acum pot doar să îi dau stop
    bStartStop.Enable = 'on';
    bStartStop.String = 'Stop';
    
    % dacă vreau să generez alt ton, dar deja a fost generat unul, trebuie
    % să șterg axele întâi pentru a nu suprapune plot-urile unul
    % peste altul
    cla(ax_signal);
    cla(ax_spectrum);

    % daca nu am hold on, plot-ul de mai jos va recrea de fapt axa ca și
    % cum ar fi una nouă, deci aici salvez xlabel, ylabel, etc.
    hold(ax_signal, 'on');  
    hold(ax_spectrum, 'on');
  
        inner_data = data{1}; % din nou valoarea tonului este un cell array
        tone = inner_data{1}; % tonul propriu zis e pe prima pozitie din array

        % la toate tonurile trebuie să împart timpul
        % cu frecvență de eșantionare, pentru a afla de fapt timpul în
        % secunde, altfel voi avea de fapt numărul de eșantioane
        t = inner_data{2}/components.sampleRate.Value; % timpul pe a 2-a poz in array
    
        % plot in timp si spectru
        plot(ax_signal, t, tone, 'b', 'LineWidth', 1.5);
    
        [Yfft, f] = spectrum_analyzer(tone, Fs);
        plot(ax_spectrum, f, Yfft, 'r', 'LineWidth', 1.5);
    
        hold(ax_signal, 'off');  
        hold(ax_spectrum, 'off');
    
        player = audioplayer(tone, Fs);
        play(player);
        setappdata(sine_tone, 'audioPlayer', player);  % salvez player in appdata
    
        src.Enable = 'off';

        timeInterval.Value = num2str(length(tone)/Fs);
        
end


% funcție pentru controlarea evenimentelor start/stop ale semnalelor
% generate
function startStop(src, ax_signal, ax_spectrum, d,Fs,sine_tone)
    
    % preiau player-ul din appdata, salvat in functia updatePlot
    player = getappdata(sine_tone,'audioPlayer');

    % preiau componentele din structura de la început
    components = guidata(src);

    if isempty(src.UserData)
        data = d("Ton de disc"); % când se pornește plot-ul pt prima dată nu am nimic în UserData, 
        % deci inițializez cu ton de disc
    else
        data = src.UserData;
    end

    % dacă semnalul este pornit (generat) și apăs pe butonul start/stop, înseamnă că
    % doresc să îl opresc. Butonul are textul 'Stop' în această situație
    if strcmp(src.String, 'Stop') && strcmp(src.Enable, 'on')
        
        stop(player);
        cla(ax_signal); % stergem axele
        cla(ax_spectrum);
        src.String = 'Start'; % după ce apăs pe buton, modific textul la 'Start'
   
    % semnalul e oprit in acest moment, dacă apăs acum pe buton, vreau să
    % îl repornesc
    elseif strcmp(src.String, 'Start') && strcmp(src.Enable, 'on')

        hold(ax_signal, 'on');  % mențin xlabel, ylabel, etc.
        hold(ax_spectrum, 'on');

            inner_data = data{1};  
            tone = inner_data{1};  

            t = inner_data{2}/components.sampleRate.Value;

            plot(ax_signal, t, tone, 'b', 'LineWidth', 1.5);
        
            [Yfft, f] = spectrum_analyzer(tone, Fs);
            plot(ax_spectrum, f, Yfft, 'r', 'LineWidth', 1.5);
        
            % revenire la comportament inițial pentru a nu suprapune
            % plot-urile
            hold(ax_signal, 'off');  
            hold(ax_spectrum, 'off');
           
            play(player);
            src.String = 'Stop'; % modifică textul butonului în 'Stop' după apăsare

   end
end