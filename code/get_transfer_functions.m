function T = get_transfer_functions(Ps, G)

    N = length(Ps);

    T = [];
    
    for i=1:N
        L = length(Ps{i});
        tmp = [];
        for j=1:L
            if (G.nodeClass(Ps{i}(j))==1)
                tmp = [tmp Ps{i}(j)];
            end
        end
        T{end+1} = tmp;
    end

end