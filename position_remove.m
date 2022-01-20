%% example of position_rm = [0, 15; 90, 0; 180 ,0];
function [hrtfData_rm, sourcePosition_rm] = position_remove(position_rm, radius,  hrtfData, sourcePosition) 
    len = length(sourcePosition);
    sz = size(position_rm);
    len2 = sz(1);
    record = zeros(1, length(position_rm));
    fprintf('<Removed Positions>\n');
    i = 1;
    while i <= len
        i = i + 1;
        for k = 1 : len2
            d = ((sourcePosition(i, 1) - position_rm(k, 1))^2 + (sourcePosition(i, 2) - position_rm(k, 2))^2)^0.5;
            if d <= radius                
                fprintf('(%d, %d)\n', sourcePosition(i,1), sourcePosition(i, 2));
                sourcePosition(i,:) = [];
                hrtfData(i,:, :) = [];
                i = i - 1;
                record(k) = 1; % the pos. is remove
            end
        end
        len = length(sourcePosition);
        if i + 1 > len
            break;
        end    
    end
    % print the position not exist!
    fprintf('\n<Positions dont exist>\n');
    for i = 1 : len2
        if position_rm(i) == 0
            fprintf('(%d, %d)\n', position_rm(i, 1), position_rm(i, 2));
        end
    end

    sourcePosition_rm = sourcePosition;
    hrtfData_rm = hrtfData;

