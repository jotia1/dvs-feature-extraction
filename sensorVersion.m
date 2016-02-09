function [ version ] = sensorVersion(filename)
    if nargin==0,
        [filename,path,filterindex]=uigetfile({'*.*dat','*.aedat, *.dat'},'Select recorded retina data file');
        if filename==0, return; end
    end
    if nargin==1,
        path='';
        filename=filename;
    end
    
    f=fopen([path,filename],'r');
    bof=ftell(f);
    line=native2unicode(fgets(f));
    tok='HardwareInterface:';
    version=128;

    while line(1)=='#',
        if strfind(line, tok) > 1
            if strfind(line, 'DAVIS') > 1
                version=240;
            end
            break;
        end
        bof=ftell(f);
        line=native2unicode(fgets(f)); % gets the line including line ending chars
    end
    
end