function loadRegulation(VoReal, Is_Array, Vo_Load, Rs)

procentRegulare = 0.006; % 0.6%
    for i = 1:length(Is_Array)
        Vo_Load(i) = VoReal - procentRegulare * Is_Array(i) / 10;
    end

    subplot('position',[0.77 0.25 0.2 0.2])
    plot(Is_Array, Vo_Load);
    hold on;  % pentru a putea afisa punctul
    indice = 0;
    % afisare punct
    for i=1:length(Is_Array)
        if Is_Array(i) == round((Vo_Load(i)/Rs) * 1000, 2)
            indice = i;
            break;
        end
    end
    if indice ~= 0 
        indiceLoad = Is_Array(indice);
        indiceVoLoad = Vo_Load(indice);
        
        scatter(indiceLoad, indiceVoLoad, 100, 'r', 'filled');  
    end
    
    title('Load Regulation (Is(Vo))');
    xlabel('Output Current (Is) [mA]');
    ylabel('Output Voltage (Vo) [V]');
    grid on;
end