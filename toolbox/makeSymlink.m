function success = makeSymlink(target,destination)
%MAKESYMLINK Summary of this function goes here
%   Detailed explanation goes here

    if isunix()
        targetPath = strrep(target,' ','\ ');
        destinationPath = strrep(destination,' ','\ ');
    else
        targetPath = target;
        destinationPath = destination;
    end
    
    % Is already a symlink? Delete.
    if ~unix(['test -L ',targetPath])
        delete(target)
    end
    
    % Is directory? Delete.
    if isfolder(target)
        rmdir(target,'s');
    end
    
    % Write the symlink command: 'ln -s [destination]/ [link]'
    linkCommand = sprintf('ln -s %s/. %s',...
        destinationPath,...
        targetPath);
    
    % Execute
    success = system(linkCommand);

end

