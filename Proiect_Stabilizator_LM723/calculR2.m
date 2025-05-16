function [R2_out] = calculR2(R2,T)
    index = 0;
    minim = 9999999;
    for i=1:length(T.Rezistenta)
        if abs(T.Rezistenta(i) - R2) < minim
            minim = abs(T.Rezistenta(i) - R2);
            index = i;
        end
    end
    R2=T.Rezistenta(index);
    R2_out=R2;

end

