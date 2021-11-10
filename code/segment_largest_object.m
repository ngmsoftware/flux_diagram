function Imax = segment_largest_object(I)

    N = size(I,1);
    M = size(I,2);

    Io = I;
    
    Io(:,1) = 0;
    Io(:,end) = 0;
    Io(1,:) = 0;
    Io(end,:) = 0;

    max_npixel = 0;
    
    for i=2:N
        for j=2:M
            if (Io(i,j))
                [npixel, Io, Iobj] = flood_fill(Io,i,j);
                if (npixel>max_npixel)
                    max_npixel = npixel;
                    Imax = Iobj;
                end
            end
        end
    end

end



function [npixel, Io, Iobj] = flood_fill(I,i,j)

    npixel = 0;

    Io = I;
    Iobj = zeros(size(I));
    
    SET = [i j];
    
    while (~isempty(SET))
       
        i = SET(1,1);
        j = SET(1,2);
        SET(1,:) = [];
        Io(i,j) = 0;
        Iobj(i,j) = 1;
        
        ii = i;
        jj = j+1;
        if (Io(ii,jj))
            SET = [SET; [ii jj]];
            Io(ii,jj) = 0;
            Iobj(ii,jj) = 1;
            npixel = npixel+1;
        end
        ii = i+1;
        jj = j;
        if (Io(ii,jj))
            SET = [SET; [ii jj]];
            Io(ii,jj) = 0;
            Iobj(ii,jj) = 1;
            npixel = npixel+1;
        end
        ii = i-1;
        jj = j;
        if (Io(ii,jj))
            SET = [SET; [ii jj]];
            Io(ii,jj) = 0;
            Iobj(ii,jj) = 1;
            npixel = npixel+1;
        end
        ii = i;
        jj = j-1;
        if (Io(ii,jj))
            SET = [SET; [ii jj]];
            Io(ii,jj) = 0;
            Iobj(ii,jj) = 1;
            npixel = npixel+1;
        end
        ii = i+1;
        jj = j+1;
        if (Io(ii,jj))
            SET = [SET; [ii jj]];
            Io(ii,jj) = 0;
            Iobj(ii,jj) = 1;
            npixel = npixel+1;
        end
        ii = i-1;
        jj = j-1;
        if (Io(ii,jj))
            SET = [SET; [ii jj]];
            Io(ii,jj) = 0;
            Iobj(ii,jj) = 1;
            npixel = npixel+1;
        end
        ii = i-1;
        jj = j+1;
        if (Io(ii,jj))
            SET = [SET; [ii jj]];
            Io(ii,jj) = 0;
            Iobj(ii,jj) = 1;
            npixel = npixel+1;
        end
        ii = i+1;
        jj = j-1;
        if (Io(ii,jj))
            SET = [SET; [ii jj]];
            Io(ii,jj) = 0;
            Iobj(ii,jj) = 1;
            npixel = npixel+1;
        end  
        
    end
    
   
end
