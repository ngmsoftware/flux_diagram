function Pis = get_loop_paths(G)

% takes a graph and returns a cel with loops paths
%
%  Algorithm
%
%   1 - Starting from a node, run through the graph until reaches the
%       departure node or has no mode place to go
%
%   2 - During the run, eliminate false loops paths (the ones that has
%       loops but the departuring node is not the one that started the process
%
%   4 - Do that for each node of the graph
%
%   PS.: this procedure might result non loops (erase them in the end)

N = length(G.nodeClass);

Pis = [];

for i=1:N
    if ( (G.nodeClass(i)==0)||(G.nodeClass(i)==3)||(G.nodeClass(i)==4) )
        Ptmp = get_loops(G, i);
        for j=1:length(Ptmp)
            Pis{end+1} = Ptmp{j};
        end
    end
end
   
Pis = erase_repeated_loops(Pis);

Pis = erase_non_loops(Pis);

%Pis = sort_paths_by_index(Pis);

% erase one length loops
Ps = [];
for i=1:length(Pis)
    if (length(Pis{i})>1)
        Ps{end+1} = Pis{i}; 
    end        
end

Pis = Ps;

end


function Piso = sort_paths_by_index(Pis)

    Piso = [];

    for i=1:length(Pis)
        Piso{end+1} = sort(Pis{i});
    end
end


function paths = erase_non_loops(paths_i)

    paths = [];

    N = length(paths_i);

    for i=1:N
        if paths_i{i}(1)==paths_i{i}(end)
            paths{end+1} = paths_i{i};
        end
    end

end


% returns a list with no repeated loops
%
function paths = erase_repeated_loops(paths_i)

    N = length(paths_i);

    paths = [];
    
    for i=1:N
        if (~is_already_in(paths_i{i},paths))
            paths{end+1} = paths_i{i};
        end
    end

end

% tests if "p" is already in set of loops "paths"
%
function it_is = is_already_in(p,paths)

    it_is = 0;
    
    N = length(paths);

    for i=1:N
        it_is = it_is || are_those_paths_the_same(p,paths{i});
    end

end


function are_they = are_those_paths_the_same(p1,p2)

    if length(p1)~=length(p2)
        are_they = 0;
        return
    end

    % start from the second element since it will repeat in the end
    are_they = all(sort(p1(2:end))==sort(p2(2:end))); 
end


% Get loops that departs from node "from"
%
%
function paths = get_loops(G, from)

    paths = {from};
    first = 1;
    
    keep_going = 1;
    while keep_going
        
        keep_going = 0;
        
        erase_idx = [];
        
        N = length(paths);
        for i=1:N
            if (paths{i}(end)~=from)||first
                [nodes, mids] = get_nodes_connected_to(paths{i}(end), G);
                first = 0;
            else
                nodes = [];
            end

            keep_going = keep_going||(~isempty(nodes));
            
            L = length(nodes);
            for j=1:L
                paths{end+1} = [paths{i} mids(j) nodes(j)];
                erase_idx = [erase_idx i];
            end

        end

        paths(erase_idx) = [];

        paths = erase_false_loppy_ones(paths);
        
    end

end



% erase paths that has loops that do not start at first node (if it is a
% loop itself, leave it there)
%
function paths = erase_false_loppy_ones(paths_i)

    N = length(paths_i);
    
    paths = [];
    loops = [];
    
    for i=1:N
        
        if (~has_loops(paths_i{i}))||(paths_i{i}(1)==paths_i{i}(end))
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

% returns a list of nodes (type 0 nodes) conected to "from". Returns also 
% the middle node (arrow nodes that links from to each node found)
%
function [nodes, middles] = get_nodes_connected_to(from, G)

    nodes = G.connections(2,G.connections(1,:)==from);
    middles = G.middle_node(G.connections(1,:)==from);

end