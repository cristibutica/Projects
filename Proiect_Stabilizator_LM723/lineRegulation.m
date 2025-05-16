function lineRegulation(Vi_Array, Vo_values)

subplot('position',[0.7 0.25 0.2 0.2])
    plot(Vi_Array, Vo_values);
    title('Line Regulation (Vo(Vi))');
    xlabel('Input Voltage (Vi) [V]');
    ylabel('Output Voltage (Vo) [V]');
    grid on;
    
end