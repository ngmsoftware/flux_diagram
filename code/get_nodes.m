function [C, Io] = get_nodes(I)

%  Take a bw image and returns the position candidates for the nodes
%  returns also the skeleted image

% Algorithm
%
%  1 - Skeleton the image until we get a "conected one pixel-length-sided 
%      graph"
%  2 - Since the branches are now one pixel tick, just return as centers
%      all pixels that have more then 2 neighboors

C = [];

% skeleton
I = bwmorph(I,'thin',Inf);

Io = I;

for i=1:size(I,1)
    for j=1:size(I,2)
        
        % if the pixel has more than 2 neighboors, add that coordinate to C
        if (I(i,j))
            
            c = I(i+1,j) + I(i-1,j) + I(i,j+1) + I(i,j-1)+...
                I(i+1,j+1) + I(i-1,j+1) + I(i+1,j-1) + I(i-1,j-1);
            
            if (c>2)
                C = [C [i; j]];
            end
            
        end
        
    end
end



end
