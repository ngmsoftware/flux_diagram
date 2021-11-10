function I = image_from_socket(port)
    javaaddpath(cd);
    
    A = Server;
    
    V = double(A.getImage(port));

    w = V(1);
    h = V(2);
    
    V = V(3:end);
    
    I = reshape(V,w,h)+0;
end

% function I = image_from_socket(port)
% 
% disp('creating server...');
% server = java.net.ServerSocket(port);
% disp('waiting connection...');
% client = server.accept();
% in = client.getInputStream();
% 
% aux = [in.read() in.read() in.read() in.read()];
% 
% w = aux(2)*2^8 + aux(1); 
% h = aux(4)*2^8 + aux(3);
% 
% V = zeros(1,w*h);
% 
% c = 0;
% i = 1;
% while c>=0
%     c = in.read();
%     if c>=0
%         V(i) = c;
%     end
%     i = i+1;
%     if (mod(i,10000)==0)
%         disp([num2str(i) ' de ' num2str(length(V)) ]);
%     end
% end
% 
% in.close();
% client.close();
% server.close();
% 
% I = reshape(V,w,h)+0;
% 
% imagesc(I);
% 
% end