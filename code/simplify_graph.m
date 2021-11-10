function graph_o = simplify_graph(graph)

% Take a graph with connections stores as cell (redundant) and returns a
% graph with connections stores as a set branches represented as a pair of
% indexes. ex.:
%
%  [i1 j1]
%  [i2 j2]
%  [i3 j3]
%    .  .
%  [in jn]
%
%  Where i_k is the index of the origin center and j_k is the index of the
%  destination so the branch links the center i_k to the center j_k

% Algrithm
%   1 - Simple test all pair of centers. 
%   2 - If there is a connection somewhere in the graph.connection variable
%       just add that connection in the new format          

N = length(graph.C);

graph_o = graph;
graph_o.connections = [];

for i = 1:N
    for j=(i+1):N
        if (is_connected(graph.connections,i,j))
            graph_o.connections = [graph_o.connections; [i j]];
        end
    end
end

end


function it_is = is_connected(conn, io, jo)

    it_is = 0;
    
    for j=1:length(conn{io})
        if (conn{io}(j)==jo)
            it_is = 1;
            return
        end
    end

end