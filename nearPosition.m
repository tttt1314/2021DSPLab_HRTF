function [distance, nearPosition] = nearPosition(sourcePosition, desiredPosition, num)
    position_size = size(sourcePosition);
    Position = zeros(1, position_size(1));
    for i = 1:position_size(1)
        Position(i) = (sourcePosition(i, 1) - desiredPosition(1))^2 + (sourcePosition(i, 2) - desiredPosition(2))^2;
    end
    nearPosition = zeros(1, num);
    distance = zeros(1, num);
    for i = 1:num
        [distance(i), nearPosition(i)] = min(Position);
        Position(nearPosition(i)) = NaN;
    end
end