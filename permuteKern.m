function [ outkern ] = permuteKern( inkern )
%PERMUTEKERN Summary of this function goes here
%   Detailed explanation goes here

%     i = randi(size(inkern, 1));
%     modifiers = [-1 0 1];
%     op = randi(size(modifiers,1));
%     
%     outkern = inkern;
%     outkern(i) = modifiers(op);
%     
%     % Now correct sum
%     offset = sum(inkern(:));

%     outkern = inkern;
%     onez = find(inkern == 1);
%     negonez = find(inkern == -1);
%     % do swap
%     outkern(onez(randi(size(onez,1)))) = -1;
%     outkern(negonez(randi(size(onez,1)))) = 1;
    
    outkern = inkern;
    while isequal(inkern, outkern)
        choice = ceil(rand(1) * 4);
        if size(find(inkern == 0), 1) > 1 && choice == 1; % Need two zeros
            zeroz = find(inkern == 0);
            i1 = randi(size(zeroz,1));
            i2 = randi(size(zeroz,1));
            while i2 == i1;
               i2 = randi(size(zeroz, 1)); 
            end
            outkern(zeroz(i1)) = -1;
            outkern(zeroz(i2)) = 1;
        elseif size(find(inkern == 1), 1) > 0 && ...  % swap a 1 and -1
                size(find(inkern == -1), 1) > 0 && ...
                choice == 2;
            onez = find(inkern == 1);
            negonez = find(inkern == -1);
            % do swap
            outkern(onez(randi(size(onez,1)))) = -1;
            outkern(negonez(randi(size(negonez,1)))) = 1;
        elseif size(find(inkern == 1), 1) > 0 && ...
                size(find(inkern == -1), 1) > 0 && ...
                choice == 3; % Set a 1 and -1 to zero each
            onez = find(inkern == 1);
            negonez = find(inkern == -1);
            % do swap
            outkern(onez(randi(size(onez,1)))) = 0;
            outkern(negonez(randi(size(negonez,1)))) = 0;
        elseif choice == 4;% && ...
                %size(find((inkern < 27 & inkern > -27) == 1), 1) >= 2; % Pick two elements and add -1 and 1
            %is = ceil(rand(2,1) * numel(inkern));
            noptions = find(inkern > -27 == 1);
            poptions = find(inkern < 27 == 1);
            nis = randsample(noptions, 1);
            pis = randsample(poptions, 1);
            %is = randsample(options, 2);
            is = [pis; nis];
            outkern(is) = outkern(is) + [1;-1];
        end
    end
        
end

