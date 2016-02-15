function [ kern ] = randKern(  )
%RANDKERN Summary of this function goes here
%   Detailed explanation goes here

    kern = randi(3, [3, 3, 3]) - 2;
    
    while sum(kern(:)) > 0;  % Pick 1 and make 0 or pick 0 and make -1
        choice = randi(2);
        if choice == 1 && size(find(kern == 1), 1) > 1; % change a 1 to 0
            onez = find(kern == 1);
            kern(onez(randi(size(onez,1)))) = 0;
        elseif size(find(kern == 0), 1) > 1
            zeroz = find(kern == 0);
            kern(zeroz(randi(size(zeroz,1)))) = -1;        
        end
    end
    
    while sum(kern(:)) < 0;  % turn -1 to 0 or 0 to 1
        choice = randi(2);
        if choice == 1 && size(find(kern == -1), 1) > 1; % turn -1 to 0
            nonez = find(kern == -1);
            kern(nonez(randi(size(nonez,1)))) = 0;
        elseif size(find(kern == 0), 1) > 1
            zeroz = find(kern == 0);
            kern(zeroz(randi(size(zeroz,1)))) = 1;        
        end
    end
    
end

