function minDist = compute_adaptive_minDist(C)

% Takes a lot of centers and estimate the correct minDist that clamp
% correctly the nearby center in the quantization process
%
% Algorithm
%   1 - measure all distances between centers
%   2 - Take the log to make scale close to each other
%   3 - sort and look for a JUMP in the distances
%       3.1 - differentiate the sorted logs and get where that
%             differentiation is maximum
%       3.2 - Take average of one before the jump and one after.

    count = 1;
    N = size(C,2);
    
    D = zeros(1,N*N-N);
    
    for i=1:N
        for j=1:N
            if (i~=j)
                D(count) = sqrt((C(:,i)-C(:,j))'*(C(:,i)-C(:,j)));
                count =count+1;
            end
        end
    end

    D = sort(D);
    
    Dl = log(1+D);
    
    dDl = diff(Dl);
    
    [t, idx] = max(dDl);
    
    th = (D(idx-1)+D(idx+1))/2;
    
    minDist = 1.5*th;    
    
end