function delta = compute_delta(loops, Tloop)

%  Take loops and computes the delta of the graph (1 - sum(single) +
%  sum(doubles) - sum(triples) + ... 
%
%  Algorithm
%   Create a function fun(x,n) that computes n_plets (recursivelly calling itself)
%   and just sum for 1 - fun(x,2) + fun(x,3) - fun(x,4) + ...

delta = sym(1);

N = length(loops);

for i=1:N
    tmp = expand(compute_nplets(loops, i, [], Tloop));
    delta = delta + ((-1).^i)*tmp;
end

end


% Computes all products of n_plets of the elements of loops. For isntance,
% if n = 3 and loops = [l1 l2 l3 l4], computes all triplets like l1*l2*l3, 
% l1*l2*l4 + l2*l3*l4 if n = 2 computes all pairs like l1*l2, l1*l3, ...
%
%  Algorithm 
%
%    1 - At first the idea is to test whether n = 1 and returns just the
%        sum. So when n = 2, we return l1*fun(loops,1) + l2*fun(loops,1) +
%        etc.. So at the end  will be l1*sum(loops) + l2*sum(loops) + ...
%
%   2 - the problem is that we are going to compute things like l1^2, l1*l2^2 
%       and the like... That is bad...
%
%   3 - To overcome this difficulty, we pass an extra argument that is a
%       set containing fobirden indexes so the n = 2 initially we do
%       l1*fun(loops,1,1) + l2*fun(loops,1,2) + l3*fun(loops,1,3) + ...
%       So, we never get l1^2, l2^2, etc...
%       Now for n = 3 we do 
%       
%       l1*fun(loops,2,1) + l2*fun(loops,2,[1 2]) + l3*fun(loops,2,[1 2 3]) + l4*fun(loops,2,[1 2 3 4])
%       
%       This way we compute
%
%       fun(loops,2,1) = l2*fun(loops,1,[1 2]) + l3*fun(loops,1,[1 2 3]) + l4*fun(loops,1,[1 2 3 4])
%                      = l2*(l3 + l4)          + l3*(l4)                 + l4*0
%       fun(loops,2,[1 2]) = l3*fun(loops,1,[1 2 3]) + l4*fun(loops,1,[1 2 3 4])
%                          = l3*(l4)                 + l4*0
%       fun(loops,2,[1 2 3]) = l4*fun(loops,1,[1 2 3 4])
%                            = l4*0
%       fun(loops,2,[1 2 3 4]) = 0
%
%       so
%
%       l1*fun(loops,2,1) = l1*l2*l3 + l1*l2*l4 + l1*l3*l3
%       l2*fun(loops,2,[1 2]) = l2*l3*l4
%       l1*fun(loops,2,1) = 0
%       l1*fun(loops,2,1) = 0
%
%       and finally we have
%
%       l1*l2*l3 + l1*l2*l4 + l1*l3*l3 + l2*l3*l4
%
%
%        PS.: The extra argument Tloop is to test and multiply loops that
%        do not touch each other. We can implment a function to return the
%        indexes of all loops that touches a particular one and "add" those
%        indexes to the args argument (so we ensure that they won´t enter
%        the computation. 

function y = compute_nplets(loops, n, args, Tloop)

N = length(loops);

y = 0;

if n==1
    for i=1:N
        if (all(i~=args))
            y = y + loops(i);
        end
    end
    return;
end


for i=1:N
    idxs = get_index_of_loops_that_touch_this_loop(Tloop, Tloop{i});
    if (all(i~=args))
        y = y + loops(i)*compute_nplets(loops, n-1, [1:i idxs], Tloop);
    end
end

end


function idxs = get_index_of_loops_that_touch_this_loop(Tloop, loop)

    N = length(Tloop);
    idxs = [];
    for i=1:N
        if does_touch(loop, Tloop{i})
            idxs = [idxs i];
        end
    end

end


function does_it = does_touch(loop1, loop2)
    
    does_it = 0;
    
    M = length(loop2);
    N = length(loop1);
    
    for i=1:N
        for j=1:M
            if loop1(i)==loop2(j)
                does_it = 1;
                return;
            end
        end
    end

end

