function graph_o = correct_serie_linked_branches(graph, I, minDist)

% takes a graph and returns a graph where any two or more arrows linked in
% serie gets an type 0 node in between them

% Algorithm
%
%  1 - for each type 1 node (arrow) get the two neigbohrs and test whether
%      either one is also type 1. 
%  2 - If one of then is, add a type 0 node in between.
%      2.1 - It can have TWO type 1 neigbohs... In this case add only ONE
%            type zero. The other one will be handles later on.

graph_o = graph;

N = length(graph_o.C);

Nc = N+1;

for i=1:N
    if (graph_o.nodeClass(i)==1)
        [c1, conn1, c2, conn2] = get_pair_of_centers_for_center(graph_o, i);
        if (graph_o.nodeClass(c1)==1) % is connected to another type 1 node
            
            graph_o.connections(conn1,:) = [];                      % eliminate connection
            newC = get_new_center_position(graph_o, i, c1, I, minDist);            % create new center in the middle
            graph_o.C = [graph_o.C newC];                           % add the new center to the graph
            graph_o.nodeClass = [graph_o.nodeClass 0];              % as a bifurcation
            graph_o.connections = [graph_o.connections; [Nc i]];   % connected either with the node i
            graph_o.connections = [graph_o.connections; [Nc c1]];  % either with node c1
            graph_o.startPoints{Nc} = [graph_o.C(:,end) graph_o.C(:,end)];  % with startpoints coinciding with the new center
            
            Nc = Nc+1;
            disp(' -- implicit serie node found. Adding a dummy connection node');
        elseif (graph_o.nodeClass(c2)==1)
            
            graph_o.connections(conn2,:) = [];
            newC = get_new_center_position(graph_o, i, c2, I, minDist); 
            graph_o.C = [graph_o.C newC];
            graph_o.nodeClass = [graph_o.nodeClass 0];
            graph_o.connections = [graph_o.connections; [Nc i]];
            graph_o.connections = [graph_o.connections; [Nc c2]];
            graph_o.startPoints{Nc} = [graph_o.C(:,end) graph_o.C(:,end)];
            
            Nc = Nc+1;
            disp(' -- implicit serie node found. Adding a dummy connection node');
        end
    end    
end


end

% Gets two nodes (indexes i and c) and returns the middle point in between.
% The good thing is that point is physically in the image path %-)
%
% Algorithm
%   1 - Flood fill from the start points of both i and c (start1 from i,
%       start2 from i, start1 from c and start2 from c) until reaches some
%       boarder.
%   2 - Do that storing the pixels of the path.
%   3 - When reaches some boarder X and verify which node Y that boarder belongs
%       to. 
%   4 - test if start1 from i reaches Y or start2 from i reaches Y, etc...
%   5 - returns the middle point in the stored path that matches Y.

function newC = get_new_center_position(graph, i, c, I, minDist)

    newC = ( graph.C(:,i)+graph.C(:,c) )/2;
    
    start1_i = graph.startPoints{i}(:,1);
    start2_i = graph.startPoints{i}(:,2);

    start1_c = graph.startPoints{c}(:,1);
    start2_c = graph.startPoints{c}(:,2);
    
    [neigbhoor_start1_i, middle1_i] = flood_fill_ultil_find_node(i, start1_i, graph.C(:,i), I, graph, minDist, []);
    [neigbhoor_start2_i, middle2_i] = flood_fill_ultil_find_node(i, start2_i, graph.C(:,i), I, graph, minDist, []);
    
    [neigbhoor_start1_c, middle1_c] = flood_fill_ultil_find_node(c, start1_c, graph.C(:,c), I, graph, minDist, []);
    [neigbhoor_start2_c, middle2_c] = flood_fill_ultil_find_node(c, start2_c, graph.C(:,c), I, graph, minDist, []);

    
    if (neigbhoor_start1_i==c)
        newC = middle1_i;
    elseif (neigbhoor_start2_i==c)
        newC = middle2_i;
    elseif (neigbhoor_start1_c==i)
        newC = middle1_c;
    elseif (neigbhoor_start2_c==i)
        newC = middle2_c;
    end
    
end


function [neighboor, middle] = flood_fill_ultil_find_node(idx_start, start, c, I, graph, minDist, path)

    Io = I;
    
    SET = [start(1)  start(2)];
    path = start;

    while (~isempty(SET))
        
        p = SET(1,:);
        SET(1,:) = [];
        
        idx = did_reach_any_center(graph, p');
        if (idx>0)&&(idx~=idx_start)
            neighboor = idx;
        
            L = size(path,2);
            middle = path(:,round(L/2));
            return;
        end
        
        i = p(1)+1;
        j = p(2);
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
            path = [path [i; j]];
        end
        i = p(1);
        j = p(2)+1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
            path = [path [i; j]];
        end
        i = p(1)-1;
        j = p(2);
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
            path = [path [i; j]];
        end
        i = p(1);
        j = p(2)-1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
            path = [path [i; j]];
        end
        i = p(1)+1;
        j = p(2)+1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
            path = [path [i; j]];
        end
        i = p(1)-1;
        j = p(2)-1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
            path = [path [i; j]];
        end
        i = p(1)+1;
        j = p(2)-1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
            path = [path [i; j]];
        end
        i = p(1)-1;
        j = p(2)+1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
            path = [path [i; j]];
        end
        
    end

end


% is p equal to one of each grapg.startPoints (if it is, returne the center
% that owns that startPoint
%
function idx = did_reach_any_center(graph, p)
    N = length(graph.nodeClass);
    
    idx = 0;
    
    for i=1:N
        if all(p==graph.startPoints{i}(:,1))||all(p==graph.startPoints{i}(:,2))
            idx = i;
        end
    end
end

% give me two nodes (with theyr centers) that are connected to
% "center_arrow" node. (remmeber that arrows have only two conections, so
% this is asking for the neighbohrs of center_arrow).
%
function [c1, conn1, c2, conn2] = get_pair_of_centers_for_center(graph, center_arrow)

    N = length(graph.connections);

    C = [];
    CONN = [];
    
    for i=1:N
        if (graph.connections(i,1)==center_arrow)
            C = [C graph.connections(i,2)];
            CONN = [CONN i];
        end
        if (graph.connections(i,2)==center_arrow)
            C = [C graph.connections(i,1)];
            CONN = [CONN i];
        end
    end

    if (length(C)==1)
        disp('oops');
    end
    
    c1 = C(1);
    conn1 = CONN(1);
    c2 = C(2);
    conn2 = CONN(2);
    
end
