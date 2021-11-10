function graph_o = consolidate_graph(graph)

% Generate a graph of the kind
%   G.C (centers)
%   G.startPoints (starting points from each node)
%   G.nodeClass (type of the node (0, 1, 3, 4)
%   G.start (index of the start node)
%   G.stop (index of the stop node)
%   G.connections = [depart_1 depart_2 depart_3 ... depart_n ];
%                   [arrive_1 arrive_2 arrive_3 ... arrive_n ];
%      where depart_i and arrive_i represent a connection from node
%      depart_i to node arrive_i 
%   G.middle_node (for each pair of depart_i and arrive_i this field tells 
%                  who is connecting them) 
%

%  Algorithm
%    1 - Just go through all graph.startPoint_associations and invert the
%        order if graph.directions is 1
%    2 - create a new field called connections that have only the 
%        graph.startPoint_associations for which directions is 0 or 1 and
%        it is in the right direction (field direction goes out, since its
%        now obsolete)
%

N = length(graph.nodeClass);




% this is to cluster type 0 nodes that are connected but there is no arrow
% between them
%
% Algorithm
%   1 - for each type 0 node, get a list of type 0 nodes that connects to that
%       node (mostlly this list will be empty).
%   2 - Create connections from the node you are analising to each one in
%   the list with gain 1 (going foward and backward)
% 
sets = [];
visited = [];
counter = 10;
for i=1:N
    if (graph.nodeClass(i)==0)&&(all(visited~=i))
        idxs = get_type0_connections(i,graph);
        if (~isempty(idxs))
            sets{end+1} = [i idxs];
            visited = [visited idxs];
            counter = counter + 1;
        end
    end
end

for i=1:length(sets)
    for j=2:length(sets{i})
        graph.connections(graph.connections==sets{i}(j)) = sets{i}(1);
        graph.startPoints_associations(graph.startPoints_associations==sets{i}(j)) = sets{i}(1);
        graph.nodeClass(sets{i}(j)) = -1; % invalidate class to avoid using this node
    end
end

for i=1:length(graph.connections)
    if (graph.connections(i,1)==graph.connections(i,2))
%        graph.connections(i,:) = [ -10 -10 ];
%        graph.directions(i) = [ -10 ];
%        graph.startPoints_associations(:,i) = [-10 ; -10];
    end
end
%
% graph.connections((graph.connections(:,1)==-10)|(graph.connections(:,2)==-10),:) = [];
% graph.startPoints_associations(:,(graph.startPoints_associations(1,:)==-10)|(graph.startPoints_associations(2,:)==-10)) = [];
% graph.directions(graph.directions==-10) = [];





graph_o.C = graph.C;

graph_o.startPoints = graph.startPoints;
graph_o.nodeClass = graph.nodeClass;
graph_o.start = sum( (1:N).*(graph_o.nodeClass==3) );
graph_o.stop = sum( (1:N).*(graph_o.nodeClass==4) );

graph_o.connections = [];
graph_o.middle_node = [];
for i=1:size(graph.startPoints_associations,2)
    if (graph.directions(i)==1)
        graph_o.connections = [graph_o.connections graph.startPoints_associations([2 1],i)];
        graph_o.middle_node = [graph_o.middle_node i];
    end
    if (graph.directions(i)==0)
        graph_o.connections = [graph_o.connections graph.startPoints_associations([1 2],i)];
        graph_o.middle_node = [graph_o.middle_node i];
    end
end


end


function idxs = get_type0_connections(j,graph)

N = length(graph.connections);

idxs = [];

for i=1:N
    nodes = graph.connections(i,:);
    if (nodes(1)==j)&&(graph.nodeClass(nodes(2))==0)
        idxs = [idxs nodes(2)];
    end
    if (nodes(2)==j)&&(graph.nodeClass(nodes(1))==0)
        idxs = [idxs nodes(1)];
    end
end


end