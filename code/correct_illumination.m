function G1o = correct_illumination(G1)

smallG1 = imresize(G1,0.02);
ilumG1 = imresize(smallG1,size(G1));
G1o = double(uint8(ilumG1-G1));
G1o(1,:) = 0; 
G1o(end,:) = 0; 
G1o(:,1) = 0; 
G1o(:,end) = 0; 

end