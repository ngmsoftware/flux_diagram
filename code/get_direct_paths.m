function Pis = get_direct_paths(G)

% takes a graph and returns a cel with direct paths
%
%  Algorithm
%
%   1 - start with one path contaning the stat node
%
%   2 - keep looping until all paths in the set of paths finishes with
%       the stop node (the first one obviously do not meet this requirement
%       since it has only one node and it is the start node)
%
%   3 - at each iteraction of the loop, do another loop for each path
%       in the set of paths. For each path, get the Nn neighboors of the
%       last node in the path.
%
%   4 - create Nn new paths by adding each neighboor to the current
%       path (that generated the neighboors) and remember to mark the
%       current path to deletion. It is like the current path died and Nn
%       new ones were born (each one with the original path plus its
%       respective neighboor).
%
%   5 - erase the ones marked and erase the ones that are loopy
%
%       5.1 - Just test wether there is some node that apeas more than
%             one time... (then it means that you went back to the same
%             node at leat one time, so you looped)
%
%   6 - terminate when everyone finishes with the stop node.

    Pis = get_paths(G, G.start, G.stop);

%    Pis = sort_paths_by_index(Pis);
end


function Piso = sort_paths_by_index(Pis)

    Piso = [];

    for i=1:length(Pis)
        Piso{end+1} = sort(Pis{i});
    end
end


function paths = get_paths(G, from, stop)

    paths = {from};
    
    keep_going = 1;
    while keep_going
        
        keep_going = 0;
        
        erase_idx = [];
        
        N = length(paths);
        for i=1:N
            if (paths{i}(end)~=stop)
                [nodes, mids] = get_nodes_connected_to(paths{i}(end), G);
            else
                nodes = [];
            end

            L = length(nodes);
            for j=1:L
                paths{end+1} = [paths{i} mids(j) nodes(j)];
                erase_idx = [erase_idx i];
            end

        end

        paths(erase_idx) = [];

        paths = erase_loppy_ones(paths);
        
        keep_going = ~does_everyone_reach_stop(paths,stop);
    end

%    paths = loops;
end


% erase paths that has loops (and put the loops into "loops" cell)
%
function paths = erase_loppy_ones(paths_i)

    N = length(paths_i);
    
    paths = [];
    loops = [];
    
    for i=1:N
        if ~has_loops(paths_i{i})
            paths{end+1} = paths_i{i};
        end
    end

end

% does path p has loops?
%
% Algorithm 
%  1 - Just test if there are two or more repeated nodes
%
function it_has = has_loops(p)
    
    p = sort(p);
    
    for i=1:(length(p)-1)
        if p(i)==p(i+1);
            it_has = 1;
            return;
        end
    end

    it_has = 0;
    
end

function did_they = does_everyone_reach_stop(paths,stop)

    did_they = 1;

    N = length(paths);
    
    for i=1:N
        did_they = did_they&&(paths{i}(end)==stop);
    end

end

% returns a list of nodes (type 0 nodes) conected to "from". Returns also 
% the middle node (arrow nodes that links from to each node found)
%
function [nodes, middles] = get_nodes_connected_to(from, G)

    nodes = G.connections(2,G.connections(1,:)==from);
    middles = G.middle_node(G.connections(1,:)==from);

end