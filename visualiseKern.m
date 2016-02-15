function [  ] = visualiseKern( kern, title, h_fig )
%VISUALISEKERN Visualise the kernel in 3D
%   Creates a figure and draws the kernel as a series of spheres in 3D
%   space with colour and size representing intensity.

    if ~exist('title', 'var')
        title = 'Kernel vis';
    end
    
    if ~exist('h_fig', 'var')
        h_fig = figure('Position', [0, 0, 640, 480]);
        movegui(h_fig,'center');
    end
    cla(h_fig);
    axis off equal square manual
    axis(ceil(reshape([size(kern) * -1.5; size(kern) * 1.5], [1, 6]))); %reshape([zeros(1, 3); size(kern) * 2], [1, 6])); %
    
    set(h_fig, 'name', title);
    set(gca,'projection','perspective','cameraviewanglemode','manual','clipping','off');
    caxis([-27 27]);
    hold on
    
    [rows, cols, deps] = size(kern);
    [X,Y,Z] = sphere(36);
    colormap jet
    cjet = colormap;
    
    draw_axis = 0;
    if draw_axis
        % Draw axis
        plot3([0 rows*2]-rows/2-1,[0 0]-cols/2-1,[0 0]-deps/2-1,'r-','linewidth',3);
        plot3([0 0]-rows/2-1,[0 cols*2]-cols/2-1,[0 0]-deps/2-1,'g-','linewidth',3);
        plot3([0 0]-rows/2-1,[0 0]-cols/2-1,[0 deps*2]-deps/2-1,'b-','linewidth',3);

        text(rows*2*1.05-rows/2-1,-cols/2-1,-deps/2-1,'X','color','r')
        text(-rows/2-1,cols*2*1.05-cols/2-1,-deps/2-1,'Y','color','g')
        text(-rows/2-1,-cols/2-1,deps*2*1.05-deps/2-1,'Z','color','b')
    end 
    
    colorbar;
    %TODO there is an error here making it draw the kernel with some kind
    %of transformation/mirroring, won't affect the gist of the kernel but
    %will affect if we start needing exact positions to be important
    for r = 0 : rows - 1
        for c = 0 : cols - 1
            for d = 0 : deps -1
                scale = kern(r+1, c+1, d + 1)/27;
                h_s = surface(X*scale + r * 2 - rows/2, Y*scale + c * 2 - cols/2, Z*scale + d * 2 - deps/2);
                colour = cjet(ceil((kern(r+1, c+1, d+1) + 27)/(27*2)*(size(cjet, 1)-1)) + 1, :);
                set(h_s,'facecolor', colour,'edgecolor','none', 'FaceAlpha', .4);
            end
        end
    end

end

