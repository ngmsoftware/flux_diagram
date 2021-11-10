function Co = quantize(C,minDist, I)

% Takes some centers C and a threshold distance and returns a set Co that
% is C quantized (with only one center per node)

% Algorithm
%
%   1 - For each center, test if it is far (distance larger than the threshold)
%       from all CURRENT centers
%   2 - If is it, add that center to the CURRENT centers (now the next
%       center have to be further from this new one also
%   3 - start with the first center (whatever, it will be some center node
%       anyway)

% Co = C(:,1);
% 
% for i=1:length(C)
%     if (is_far_from_all(C(:,i),Co,minDist))
%         Co = [Co C(:,i)];
%     end
% end


Ctmp = {C(:,1)};

for i=1:length(C)
%     if (is_far_from_all(C(:,i),Co,minDist))
%         Ctmp{end+1} = C(:,i);
%     else
        Ctmp = add_to_closer(Ctmp,C(:,i),minDist);
%    end
end

% average the centers and transform cell into matrix
%   OBS.: IMPORTANT! the center MUST belong to the image I (some functions
%   search for the cneter IN the image)
Co = [];
for i=1:length(Ctmp)
    tmp = get_closest_to_I(round(mean(Ctmp{i},2)), I);
    Co = [Co tmp];
end

end

% Returns a point close to the point c but that belongs to I
%
% Algorithm
%   1 - keep testing in a start like position roound c until reach a point
%   in the image
function C = get_closest_to_I(c, I)

    C = c;
    count = 1;

    keep_going = 1;
    while keep_going
        switch mod(count,8)
            case 0
                C = c + fix(count*[1; 0]/8);
            case 1
                C = c + fix(count*[0; 1]/8);
            case 2
                C = c + fix(count*[-1; 0]/8);
            case 3
                C = c + fix(count*[0; -1]/8);
            case 4
                C = c + fix(count*[1; 1]/8);
            case 5
                C = c + fix(count*[-1; -1]/8);
            case 6
                C = c + fix(count*[1; -1]/8);
            case 7
                C = c + fix(count*[-1; 1]/8);
        end
        count = count+1;

        if I(C(1),C(2))
            keep_going = 0;
        end
    end

end


%  Get a set Ctmp_i of centers and add C to the set at which C is closest
%  to some element in the set (acording to minDist) if no element of any
%  all sets ha no element close (in minDist sense) to C, create a new set
%  and put C there...
%
function Ctmp = add_to_closer(Ctmp_i, C, minDist)
    Ctmp = Ctmp_i;

    N = length(Ctmp);

    for i=1:N
        L = size(Ctmp{i},2);
        for j=1:L
            distance = sqrt((C-Ctmp{i}(:,j))'*(C-Ctmp{i}(:,j)));
            if distance<minDist
                Ctmp{i} = [Ctmp{i} C];
                return
            end
        end
    end  
    
    Ctmp{end+1} = C;

end


function y = is_far_from_all(c, S, minDist)

y = 1;
for i=1:size(S,2)
    distance = sqrt((c-S(:,i))'*(c-S(:,i)));
    y = y&&(distance>minDist);
end

end