function [ convs, knames, ksum ] = loadKernals( dirname )
%LOADKERNALS Load all kernals from kernals directory
%   Load all kernals from the kernals directory as a cell array of kernals

    persistent loaded_kernals
    % TODO stop redundant loading...

    filescsv = dir([dirname, '/*.csv']);
    filesmat = dir([dirname, '/*.mat']);
    numcsv = size(filescsv, 1);
    nummat = size(filesmat, 1);
    numfiles = numcsv + nummat;
    
    % All in one set
    if numfiles == 1 && nummat == 1 && strcmp(filesmat(1).name, 'kset.mat')
        o = load([dirname, '/', filesmat(1).name], 'kset');
        convs = o.kset';
        nconvs = size(convs,1);
        knames = cell(nconvs, 1);
        ksum = cell(nconvs, 1);
        for i = 1:nconvs
            knames{i} = num2str(i);
            ksum{i, 1} = sum(sum(sum(abs(convs{i}))));
        end 
        return;
    end

    convs = cell(numfiles, 1); 
    knames = cell(numfiles, 1);
    ksum = cell(numfiles, 1);
    
    % Load csv's
    for i = 1:numcsv
        convs{i} = repmat(load([dirname, '/', filescsv(i).name]), [1, 1, 3]);
        knames{i} = filescsv(i).name;
        ksum{i, 1} = sum(sum(sum(abs(convs{i}))));
    end
    
    % Load mats
    for ii = 1:nummat;
        convs{numcsv + ii} = load([dirname, '/', filesmat(ii).name]);
        convs{numcsv + ii} = convs{numcsv + ii}.kernel;
        knames{numcsv + ii} = filesmat(ii).name;
        ksum{numcsv + ii, 1} = sum(sum(sum(abs(convs{numcsv + ii}))));
    end

    loaded_kernals = filescsv;
end

