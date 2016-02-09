function [ is_cluster ] = isGPUCluster(  )
%ISGPUCLUSTER Return 1 if running on a GPU cluster and 0 otherwise.
%  	Note this file is specific for the GPU cluster 'Goliath' running at the
%  	University of Queensland. 

    [ ~, hostname ] = system('hostname');
    is_cluster = 0;
    if strfind(hostname, 'goliath') > 0;
        is_cluster = 1;
    end
    
end

