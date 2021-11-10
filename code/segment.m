function Io = segment(I, lastTh)

% Takes a gray image and returna s BW image with ONE object (hopefully the
% graph). Also takes a parameter lastTh that is the amount of thresolhd we
% add even after finishing search for one object to get a more "smooth"
% region.

% Algorithm
%
%   1 - star with a low threshold (that will segment poorly and get several
%       disconnected regions.
%   2 - Segment with this bad threshold and test if there are more than one
%       object
%   3 - Increment the threshold until the segmentation returns only one
%       object
%   4 - Add a lastTh to get a more smooth region
%
   
th = (max(max(I))-min(min(I)))/2;
Io = I>th;

return

end

function aux

I(1:2,:) = 0;
I(end:(end-1),:) = 0;
I(:,1:2) = 0;
I(:,end:(end-1)) = 0;

% bad thresolhd
th = 1.3*( max(max(I))+min(min(I)) )/2;
keep_going = 1;
while keep_going

    % increase a bit...
    th = th-1;
    
    Io = I>th;
    
    % test if it has only one object
    keep_going = (~has_one_object(Io))||(sum(sum(Io))<100);
   
    imagesc(Io);
    
    drawnow();
    
end

Io = I>(th+lastTh);

imagesc(Io);
drawnow();
end

% Test if there is one object.
%
%   1 - Search for the first pixel in the object.
%   2 - Flood fill this pixel
%   3 - If that makes the image with pratically no pixels. Bingo! There is
%       only one object. Othewise there is not...
%
function it_has = has_one_object(I)
    
    N = size(I,1);
    M = size(I,2);
    T = N*M;

    it_has = 0;
    
    for i=1:N
        for j=1:M
            if (I(i,j))
                I = flood_fill(I,i,j);
                if (sum(sum(I))<(100))
                    it_has = 1;
                    return;
                else
                    it_has = 0;
                    return
                end
            end
            
        end
    end
       
end


function Io = flood_fill(I,i,j)

    Io = I;
    
    SET = [i j];

    while (~isempty(SET))
        
        p = SET(1,:);
        SET(1,:) = [];
        
        i = p(1)+1;
        j = p(2);
        try
        if (Io(i,j))
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        catch
        end
        i = p(1);
        j = p(2)+1;
        try
        if (Io(i,j))
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        catch
        end
        i = p(1)-1;
        j = p(2);
        try
        if (Io(i,j))
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        catch
        end
        i = p(1);
        j = p(2)-1;
        try
        if (Io(i,j))
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        catch
        end
        i = p(1)+1;
        j = p(2)+1;
        try
        if (Io(i,j))
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        catch
        end
        i = p(1)-1;
        j = p(2)-1;
        try
        if (Io(i,j))
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        catch
        end
        i = p(1)+1;
        j = p(2)-1;
        try
        if (Io(i,j))
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        catch
        end
        i = p(1)-1;
        j = p(2)+1;
        try
        if (Io(i,j))
            Io(i,j) = 0;
            SET = [SET; i j];
        end
        catch
        end
        
    end
        
        
end
