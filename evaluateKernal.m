function [ count ] = evaluateKernal( data, okernals, testKernal )
%EVALUATEKERNAL Summary of this function goes here
%   Given a kernal and some data, return a real valued number describing
%   the kernals performance as a number of pixels it was maximum for.

    return; % function is hardcoded, don't use.
    
    
    
    
    okernals{end + 1} = testKernal;
    res = zeros([size(okernals, 1), 190*4, 180, size(data, 3)]); %*4 for all inputs of data

    % Serial implementation
    for i=1:size(okernals, 1);
        kern = okernals{i, :, :, :};
        res(i, :, :, :) = convn(data, kern, 'same') ./ sum(abs(kern(:))); %conv and normalise
    end

    [maxs imaxs] = max(res(:, :, :, :));
    wins = imaxs == 7;
    count = sum(wins(:));
    

end

