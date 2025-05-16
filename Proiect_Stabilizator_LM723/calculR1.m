function [R1_out] = calculR1(R1,T)

if R1 > 6200
    R1=6200;
    R1_out=R1;
else
    index = 0;
    minim = 9999999;
    for i=1:length(T.Rezistenta)
        if abs(T.Rezistenta(i) - R1) < minim
            minim = abs(T.Rezistenta(i) - R1);
            index = i;
        end
    end
    R1=T.Rezistenta(index);
    R1_out=R1;
end

end