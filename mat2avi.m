files = dir('results/*.mat');
tic
for f = 1 : numel(files);
    filename = ['results/' files(f).name];
    outname = ['results/vids/' files(f).name(1:end-4), '.avi'];
    fprintf('Converting %s\n', outname);
    visualiseEvolution(filename, 'y', outname);
end
toc