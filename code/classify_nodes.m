function [nodeClasses, startPoints] = classify_nodes(C, I, minDist)

% Takes a set of quantized centers C, an skeletonized image I and a
% threshold distance minDist
%
% returns a vector with N node classes
%   0 -> bifurcation or sum
%   1 -> arrow
%   3 -> start node (bifurcation)
%   4 -> end note (sum)
%
% and N cells each one with the points at the edge of the circle defined by
% minDist. Those will be the starting points to the branches. Is some node 
% has, for instance, 4 starting points is because it connects with 4 nodes.

% Algorithm
%
%  1 - For each center, flood-fill from the center pixel and keep measuring
%      the distace of the flooded pixels. The flood fill will grow as a
%      tree from the center to the edges of the circle defined by minDist
%  2 - If that distance becomes larger than minDist, that is a edge point.
%      Increment number of connections of the current node and return.
%  3 - If the node has 2 connections it will be an arrow, if not will be a
%      sum or bifucation.


% initialize
startPoints = {};
nodeClasses = zeros(1,length(C));

% classify each node
for i=1:length(C)
    [nodeClasses(i), startPoints_c] = classify_node(C(:,i), I, minDist);
    startPoints{i} = startPoints_c;
    
    % if it is a start or end point, RE-classify it
    if (is_start_node(i, C))
        nodeClasses(i) = 3;
    end

    if (is_end_node(i,C))
        nodeClasses(i) = 4;
    end

end

end

% start node will be leftmost node
%
function it_is = is_start_node(c, C)
    it_is = 1;

    for i=1:length(C)
        if (i~=c)
            it_is = it_is && (C(2,c)<C(2,i));
        end
    end
    
end

% end node will be rightmost node
%
function it_is = is_end_node(c, C)
    it_is = 1;

    for i=1:length(C)
        if (i~=c)
            it_is = it_is && (C(2,c)>C(2,i));
        end
    end
    
end

% Classify a single node (counts how many edge points (starting points) and
% decide the class. Returns also the points in the edge of the circle
% (starting points)
%
function [nodeClass, startPoints_c] = classify_node(c, I, minDist)

[nEnds, I2, ends] = fill_counting(I, c, minDist, 0, c, []);

nodeClass = nEnds == 2;

startPoints_c = ends;

end


% Flood-fill until reaches the edge. Returns the edge point
%
function [nEnds, Io, ends] = fill_counting(I, c, minDist, nEnds0, c0, ends0)

    Io = I;
    nEnds = nEnds0;
    ends = ends0;

    if (sqrt((c-c0)'*(c-c0))>minDist)
        Io(c(1),c(2)) = 0;
        Io(c(1)+1,c(2)) = 0;
        Io(c(1)-1,c(2)) = 0;
        Io(c(1),c(2)+1) = 0;
        Io(c(1),c(2)-1) = 0;
        Io(c(1)+1,c(2)+1) = 0;
        Io(c(1)-1,c(2)-1) = 0;
        Io(c(1)+1,c(2)-1) = 0;
        Io(c(1)-1,c(2)+1) = 0;
        nEnds = nEnds0+1;
        ends = [ends0 [c(1); c(2)]];
        return;
    end

    % uses 8-neighboohood
    %
    
    x1 = c(1)+1;
    y1 = c(2);

    if (Io(x1,y1))
        Io(x1,y1) = 0;
        [nEnds, Io, ends] = fill_counting(Io, [x1; y1], minDist, nEnds, c0, ends);
    end
    
    x2 = c(1);
    y2 = c(2)+1;
    
    if (Io(x2,y2))
        Io(x2,y2) = 0;
        [nEnds, Io, ends] = fill_counting(Io, [x2; y2], minDist, nEnds, c0, ends);
    end
    
    x3 = c(1)-1;
    y3 = c(2);
    
    if (Io(x3,y3))
        Io(x3,y3) = 0;
        [nEnds, Io, ends] = fill_counting(Io, [x3; y3], minDist, nEnds, c0, ends);
    end
    
    x4 = c(1);
    y4 = c(2)-1;
    
    if (Io(x4,y4))
        Io(x4,y4) = 0;
        [nEnds, Io, ends] = fill_counting(Io, [x4; y4], minDist, nEnds, c0, ends);
    end

    x5 = c(1)+1;
    y5 = c(2)-1;

    if (Io(x5,y5))
        Io(x5,y5) = 0;
        [nEnds, Io, ends] = fill_counting(Io, [x5; y5], minDist, nEnds, c0, ends);
    end
    
    x6 = c(1)-1;
    y6 = c(2)+1;
    
    if (Io(x6,y6))
        Io(x6,y6) = 0;
        [nEnds, Io, ends] = fill_counting(Io, [x6; y6], minDist, nEnds, c0, ends);
    end
    
    x7 = c(1)+1;
    y7 = c(2)+1;
    
    if (Io(x7,y7))
        Io(x7,y7) = 0;
        [nEnds, Io, ends] = fill_counting(Io, [x7; y7], minDist, nEnds, c0, ends);
    end
    
    x8 = c(1)-1;
    y8 = c(2)-1;
    
    if (Io(x8,y8))
        Io(x8,y8) = 0;
        [nEnds, Io, ends] = fill_counting(Io, [x8; y8], minDist, nEnds, c0, ends);
    end    
end
