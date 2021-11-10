function T = mason_formula(Tdir, Tloop, G, gs)

% Compute Mason Formula
% 
%

M = length(G.nodeClass);

N = 0;

for i=1:M
    N = N + (G.nodeClass(i)==1);
end

loops = [];
K = length(Tloop);
for i=1:K
    loop_tmp = sym(1);
    L = length(Tloop{i});
    for j=1:L
        loop_tmp = loop_tmp*gs(Tloop{i}(j));
    end
    loops = [loops loop_tmp];
end

dirs = [];
K = length(Tdir);
for i=1:K
    dir_tmp = sym(1);
    L = length(Tdir{i});
    for j=1:L
        dir_tmp = dir_tmp*gs(Tdir{i}(j));
    end
    dirs = [dirs dir_tmp];
end

delta = compute_delta(loops, Tloop);

deltas = [];
for i=1:length(dirs)
    [newloops, newTloop] = take_loops_that_touch_path(loops, Tloop, Tdir{i}, G);
    deltas = [deltas compute_delta(newloops, newTloop)];
end

T = simple(sum(dirs.*deltas)/delta);

end


function [newloops, newTloop] = take_loops_that_touch_path(loops, Tloop, dir, G)

    newloops = [];
    newTloop = [];

    for i=1:length(loops)
%        if ( ~is_gain_present_in_loop(dir, Tloop{i}) )
        if ( ~loop_touches_path(dir, Tloop{i}, G) )
            newloops = [newloops loops(i)];
            newTloop{end+1} = Tloop{i};
        end
        
    end



end


function it_is = is_gain_present_in_loop(dir, loop)

    it_is = 0;
    
    L = length(dir);
    M = length(loop);
    for i=1:L
        for j=1:M
            if (dir(i)==loop(j))
                it_is = 1;
            end
        end
    end
    
end

function yn = loop_touches_path(dir, Tloop, G)

    yn = 0;

    directPathVertex = getAllVertexInPath(dir, G);
   
    loopVertex = getAllVertexInPath(Tloop, G);
   
    for i=1:length(directPathVertex)
        if any(directPathVertex(i)==loopVertex)
            yn = 1;
            return;
        end
    end
   

end



function vertex = getAllVertexInPath(Tloop, G) 

    vertex = [];

    for i=1:length(G.middle_node)
        if any(Tloop==G.middle_node(i))
            vertex = [vertex G.connections(:,i)'];
        end
    end

    vertex = unique(vertex);
    
end

