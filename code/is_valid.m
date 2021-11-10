function is_it = is_valid(G)

%  INCOMPLETE!
%
%

    N = length(G.nodeClass);
    
    for i=1:N
        if (G.nodeClass(i)~=1)
            depart = is_all_depart(i, G);
            arrive = is_all_arrive(i, G);

            if depart&&(G.nodeClass(i)~=3)
                it_is = 0;
                return;
            end
            if arrive&&(G.nodeClass(i)~=4)
                it_is = 0;
                return;
            end
        end
    end

    it_is = 1;
    
end



function it_is = is_all_depart(node, G)
it_is = 1;
end