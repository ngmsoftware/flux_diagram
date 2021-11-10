function graph_o = get_directions(graph, I, minDist)

% Takes a graph, an skeletonized image and a thresold distance and returns
% a new graph with a new field "directions" (that contains -1 for num arrow
% branches, 0 for start1 to start2 directions and 1 for start2 to start1
% directions. 
%  start1 is the first starting point for the node and start2 is the second. 

% Algorithm
%   1 - For each arrow node get the ends of the arrow (points with only onw
%       neigbhoor).
%   2 - compute the average of the arrow ends and test the distance to
%       start1 and start2
%   3 - However is closer is the originating start point.
%   4 - associate which start point (1 or 2) is "besides" which node. For
%       instance one could have a direction from start1 to start2. So if
%       node x is linked to start1 and node y is linked with start2, then
%       the direction is from node x to node y (that are nodes type 0)


    graph_o = graph;
    
    directions = get_nodes_directions(graph,I, minDist);

    graph_o.directions = directions;
    
    graph_o = associate_startPoints_to_nodes(graph_o, I, minDist);
    
end

function graph_o = associate_startPoints_to_nodes(graph, I, minDist)
    graph_o = graph;
    
    assoc = [];
    
    N = length(graph_o.nodeClass);
    
    for i=1:N
        if (graph_o.nodeClass(i)==1)
            
            start1 = graph_o.startPoints{i}(:,1);
            start2 = graph_o.startPoints{i}(:,2);
            
            c = graph_o.C(:,i);
            neighboor1 = flood_fill_ultil_find_node(i, start1, c, I, graph, minDist);
            neighboor2 = flood_fill_ultil_find_node(i, start2, c, I, graph, minDist);
            
            assoc = [assoc [neighboor1; neighboor2]];
            
        else
            assoc = [assoc [0; 0]];
        end            
    end
    
    graph_o.startPoints_associations = assoc;
    
end

function neighboor = flood_fill_ultil_find_node(idx_start, start, c, I, graph, minDist)

    Io = I;
    
    SET = [start(1)  start(2)];

    while (~isempty(SET))
        
        p = SET(1,:);
        SET(1,:) = [];
        
        idx = did_reach_any_center(graph, p');
        if (idx>0)&&(idx~=idx_start)
            neighboor = idx;
            return;
        end
        
        i = p(1)+1;
        j = p(2);
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1);
        j = p(2)+1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1)-1;
        j = p(2);
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1);
        j = p(2)-1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1)+1;
        j = p(2)+1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1)-1;
        j = p(2)-1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1)+1;
        j = p(2)-1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1)-1;
        j = p(2)+1;
        if ( Io(i,j)&&sqrt((c(1)-i).^2+(c(2)-j).^2)>minDist )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        
    end
    

end

% is p a center for any node?
%
function idx = did_reach_any_center(graph, p)
    N = length(graph.nodeClass);
    
    idx = 0;
    
    for i=1:N
        if all(p==graph.C(:,i))
            idx = i;
        end
    end
end


% for each arrow, give me 0 if the arrow departs from startPoint1 to
% startPoint2 or give me 1 if is the oposite. Give me -1 if it is not an
% arrow (so is not departing from anywere)
%
%  Algorithm
%
%  1 - for each arrow in the graph do
%
%  2 - flood fill to find the ends of the arrow (points with only one
%      neighboor.
%
%  3 - Take the average of the end points of the arrow and test whos is
%      closer (start1 or 2)
%
function directions = get_nodes_directions(graph,I, minDist)

    directions = [];

    N = length(graph.C);
    
    for i=1:N
        if (graph.nodeClass(i)==1)
            
            p = get_node_notable_points(graph.C(:,i), I, minDist);
            
            averageP = 0;
            n = size(p,2);
            for j=1:n
                averageP = averageP + p(:,j);
            end
            averageP = averageP/n;
            
            v = averageP-graph.startPoints{i}(:,1);
            d1 = sqrt(v'*v);
            v = averageP-graph.startPoints{i}(:,2);
            d2 = sqrt(v'*v);
            
            directions = [directions (d1>d2)+0];
            
        else
            directions = [directions -1];
        end
    end

end


% % returns the averate of the centers (pixels with mode 
% %
% function Cav = get_average_centers(c, I, minDist)
% 
%     Cav = [0; 0];
%     n = 0;
% 
%     Io = I;
% 
%     SET = [c(1) c(2)];
% 
%     while (~isempty(SET))
%         
%         p = SET(1,:);
%         SET(1,:) = [];
%         
%         n = get_number_of_neighbhoors(p,I);
%         
%         if (n>2)
%             Cav = Cav + [p(1); p(2)];
%             n = n+1;
%         end
%         
%         i = p(1)+1;
%         j = p(2);
%         if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
%             Io(i,j) = 0;
%             SET = [SET; i j];
%         end
%         i = p(1);
%         j = p(2)+1;
%         if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
%             Io(i,j) = 0;
%             SET = [SET; i j];
%         end
%         i = p(1)-1;
%         j = p(2);
%         if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
%             Io(i,j) = 0;
%             SET = [SET; i j];
%         end
%         i = p(1);
%         j = p(2)-1;
%         if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
%             Io(i,j) = 0;
%             SET = [SET; i j];
%         end
%         i = p(1)+1;
%         j = p(2)+1;
%         if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
%             Io(i,j) = 0;
%             SET = [SET; i j];
%         end
%         i = p(1)-1;
%         j = p(2)-1;
%         if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
%             Io(i,j) = 0;
%             SET = [SET; i j];
%         end
%         i = p(1)+1;
%         j = p(2)-1;
%         if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
%             Io(i,j) = 0;
%             SET = [SET; i j];
%         end
%         i = p(1)-1;
%         j = p(2)+1;
%         if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
%             Io(i,j) = 0;
%             SET = [SET; i j];
%         end
%         
%     end
%     
%     Cav = Cav/n;
%         
%         
% end




% give me all arrows ends for that center
%
function P = get_node_notable_points(c, I, minDist)

    P = [];

    Io = I;

    SET = [c(1) c(2)];

    while (~isempty(SET))
        
        p = SET(1,:);
        SET(1,:) = [];
        
        n = get_number_of_neighbhoors(p,I);
        
        if (n==1)
            P = [P [p(1); p(2)]];
        end
        
        i = p(1)+1;
        j = p(2);
        if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1);
        j = p(2)+1;
        if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1)-1;
        j = p(2);
        if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1);
        j = p(2)-1;
        if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1)+1;
        j = p(2)+1;
        if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1)-1;
        j = p(2)-1;
        if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1)+1;
        j = p(2)-1;
        if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        i = p(1)-1;
        j = p(2)+1;
        if (Io(i,j)&&( sqrt((i-c(1)).^2+(j-c(2)).^2))<minDist  )
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        
    end
        
        
end


% how many neighboors does pixel p have? (in I)
%
function n = get_number_of_neighbhoors(p,I)

    n = 0;

    i = p(1)+1;
    j = p(2);
    if (I(i,j))
        n = n+1;
    end
    i = p(1);
    j = p(2)+1;
    if (I(i,j))
        n = n+1;
    end
    i = p(1)-1;
    j = p(2);
    if (I(i,j))
        n = n+1;
    end
    i = p(1);
    j = p(2)-1;
    if (I(i,j))
        n = n+1;
    end
    i = p(1)+1;
    j = p(2)+1;
    if (I(i,j))
        n = n+1;
    end
    i = p(1)-1;
    j = p(2)-1;
    if (I(i,j))
        n = n+1;
    end
    i = p(1)+1;
    j = p(2)-1;
    if (I(i,j))
        n = n+1;
    end
    i = p(1)-1;
    j = p(2)+1;
    if (I(i,j))
        n = n+1;
    end
end