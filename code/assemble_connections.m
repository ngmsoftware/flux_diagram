function graph = assemble_connections(C, startPoints,I, minDist, nodeClass)

% Receives a set of quantized centers C, the starting point cells with the
% edge points for each center, an skeletized image I, a threshold distance 
% and a set of nodeClasses
%
% Returns a graph 
%   G.C           -> centers
%   G.startPoints -> edge points for each center
%   G.connections -> index of destination nodes for each node
%   G.nodeClass   -> class of each center

% Algorithm
%
%  1 - For each center and for each edge point (starting point) flood-fill
%      in the direction out of the center until reach another center
%      boundry.
%  2 - The arrived center will be the neighbor.


N = length(C);

% initialize
graph.C = C;
graph.startPoints = startPoints;
graph.connections = {};
graph.nodeClass = nodeClass;

for i=1:N
    starts = startPoints{i};
    
    connectedNodes = [];
    for j=1:size(starts,2);
        [conn, startPoints] = get_whos_connected_to_this(starts(:,j), C(:,i), startPoints, C, I, minDist);
        connectedNodes = [connectedNodes conn];
    end  
    graph.connections{i} = connectedNodes;

end

end

% returns who is connected with p (that is departing from c)
%
function [conn, startPoints] = get_whos_connected_to_this(p, c, startPoints0, C, I, minDist)

    startPoints = startPoints0;

    p2 = pick_direction_outside(p,I,c);
    
    I(p(1),p(2)) = 0; % to be sure it is not going back...
    
    [i, It] = fill_path(I, p2, c, C, minDist);
    
    conn = i;
end

% Given a starting point p, returns another one (a neighboor) that is
% surelly going OUT of the center c
%
function po = pick_direction_outside(p , I, c)
    minDist = sqrt( (p-c)'*(p-c) );

    x1 = p(1)+1;
    y1 = p(2);
    po = [x1; y1];
    distance = sqrt((po-c)'*(po-c) );
    if (distance>minDist)&&(I(x1,y1))
        return
    end
    
    x1 = p(1);
    y1 = p(2)+1;
    po = [x1; y1];
    distance = sqrt((po-c)'*(po-c) );
    if (distance>minDist)&&(I(x1,y1))
        return
    end

    x1 = p(1)-1;
    y1 = p(2);
    po = [x1; y1];
    distance = sqrt((po-c)'*(po-c) );
    if (distance>minDist)&&(I(x1,y1))
        return
    end
    
    x1 = p(1)-1;
    y1 = p(2);
    po = [x1; y1];
    distance = sqrt((po-c)'*(po-c) );
    if (distance>minDist)&&(I(x1,y1))
        return
    end
    
    x1 = p(1)+1;
    y1 = p(2)-1;
    po = [x1; y1];
    distance = sqrt((po-c)'*(po-c) );
    if (distance>minDist)&&(I(x1,y1))
        return
    end
    
    x1 = p(1)-1;
    y1 = p(2)+1;
    po = [x1; y1];
    distance = sqrt((po-c)'*(po-c) );
    if (distance>minDist)&&(I(x1,y1))
        return
    end
    
    x1 = p(1)+1;
    y1 = p(2)+1;
    po = [x1; y1];
    distance = sqrt((po-c)'*(po-c) );
    if (distance>minDist)&&(I(x1,y1))
        return
    end
    
    x1 = p(1)-1;
    y1 = p(2)-1;
    po = [x1; y1];
    distance = sqrt((po-c)'*(po-c) );
    if (distance>minDist)&&(I(x1,y1))
        return
    end
end

% Flood-fill until reaches the boundries of another center
%
function [center, I] = fill_path(I0, p, c, C, minDist)

    I = I0;

    % make sure it will not go back
    I(p(1),p(2)) = 0;
    
%    imagesc( I((p(1)-80):(p(1)+80),(p(2)-80):(p(2)+80)) );
%    pause();
    
    for i=1:size(C,2)
        distance = sqrt((p-C(:,i))'*(p-C(:,i)) );
        if (distance<minDist)
            center = i;
            return;
        end
    end
    
    
    
    % after each call to fill_path, return... Remember that we are
    % interested only in the first one that reaches another center. So, the
    % first one to reach, "tell" the others to give up.
    
    x1 = p(1)+1;
    y1 = p(2);
    if (I(x1,y1))
        if ( sqrt((c-[x1; y1])'*(c-[x1; y1]))>minDist )
            I(x1,y1) = 0;
            [center, I] = fill_path(I, [x1; y1], c, C, minDist);
            return;
        end
    end
    

    x1 = p(1);
    y1 = p(2)+1;

    if (I(x1,y1))
        if ( sqrt((c-[x1; y1])'*(c-[x1; y1]))>minDist )
            I(x1,y1) = 0;
            [center, I] = fill_path(I, [x1; y1], c, C, minDist);
            return;
        end        
    end

    
    x1 = p(1)-1;
    y1 = p(2);

    if (I(x1,y1))
        if ( sqrt((c-[x1; y1])'*(c-[x1; y1]))>minDist )
            I(x1,y1) = 0;
            [center, I] = fill_path(I, [x1; y1], c, C, minDist);
            return;
        end        
    end
    
    
    x1 = p(1);
    y1 = p(2)-1;

    if (I(x1,y1))
        if ( sqrt((c-[x1; y1])'*(c-[x1; y1]))>minDist )
            I(x1,y1) = 0;
            [center, I] = fill_path(I, [x1; y1], c, C, minDist);
            return;
        end        
    end
    
    x1 = p(1)+1;
    y1 = p(2)-1;

    if (I(x1,y1))
        if ( sqrt((c-[x1; y1])'*(c-[x1; y1]))>minDist )
            I(x1,y1) = 0;
            [center, I] = fill_path(I, [x1; y1], c, C, minDist);
            return;
        end        
    end
    
    
    x1 = p(1)-1;
    y1 = p(2)+1;

    if (I(x1,y1))
        if ( sqrt((c-[x1; y1])'*(c-[x1; y1]))>minDist )
            I(x1,y1) = 0;
            [center, I] = fill_path(I, [x1; y1], c, C, minDist);
            return;
        end        
    end
    
    
    
    x1 = p(1)+1;
    y1 = p(2)+1;

    if (I(x1,y1))
        if ( sqrt((c-[x1; y1])'*(c-[x1; y1]))>minDist )
            I(x1,y1) = 0;
            [center, I] = fill_path(I, [x1; y1], c, C, minDist);
            return;
        end        
    end
    
    x1 = p(1)-1;
    y1 = p(2)-1;

    if (I(x1,y1))
        if ( sqrt((c-[x1; y1])'*(c-[x1; y1]))>minDist )
            I(x1,y1) = 0;
            [center, I] = fill_path(I, [x1; y1], c, C, minDist);
            return;
        end        
    end
    
    disp('center problem... try a different minDist (larger or smaller)');
    
end