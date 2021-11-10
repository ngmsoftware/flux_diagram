clear();
clc();
close('all')

% avoid compute using the whole image
scale = 0.6;

option = 'camera';

switch (option)
    case 'file'

        %read and pre-process image...
        % 1!, 2, (3), (4), 5!, 6, (7), (8), 9, 10, 11!, 12!, 13!, 14, (15),
        % (16), 17!, 18!, 19, 20!, (21), 22
        disp('reading image...');
        Img = double(imread('g18.jpg'));
        Img = imresize(Img,scale);
        G1 = (Img(:,:,1)+Img(:,:,2)+Img(:,:,3))/3;

    case 'net'
        
        G1 = image_from_socket(6660);
        G1 = 255*(G1-min(min(G1)))/(max(max(G1)) - min(min(G1)));
        Img = cat(3,G1,G1,G1);

    case 'camera'
        
        tmp = double(image_from_camera());
        G1 = imresize(tmp(:,:,1),[480 640]);
        G1 = 255*(G1-min(min(G1)))/(max(max(G1)) - min(min(G1)));
        Img = cat(3,G1,G1,G1);
end

disp('segmenting and filtering...');

G1 = correct_illumination(G1);
G1 = segment(G1, -15); % large pen
%G1 = segment(G1, -20); % large pen
%G1 = segment(G1, -50);  % thin pen
%G1 = medfilt2(G1,round([12 12]*scale)); % large pen
G1 = medfilt2(G1,round([2 2]));
G1 = segment_largest_object(G1);

% get position of the nodes (balls and arrows). Each node will have
% multiples centers that have to be quantized later.
disp('looking for nodes...');
[C, I] = get_nodes(G1);

% radius that includes the whole nodes (no pixel from the node skeleton can
% be outside this radius)
%
%    could allow this if the code detect that the arrow is a dead end and
%    ignore the brench
%minDist = 65*scale; % g13
minDist = compute_adaptive_minDist(C);
disp(minDist);
%minDist = 15; % img 16 (because of bad drawning)
%minDist = 75*scale; % img 9 (because of too short edged drawning)

% quantize the centers (since each node never bifurcate preciselly from the
% same point)
disp('quantizing node centers...');
C = quantize(C,minDist, I);

% classify each node 
%   0 -> bifurcation or sum
%   1 -> arrow
%   3 -> start node (bifurcation)
%   4 -> end note (sum)
disp('identifying nodes...');
[nodeClass, startPoints] = classify_nodes(C,I,minDist);

% connect the nodes
disp('assembling connections and constructing graph...');
% minDist here do not need to be big enough. In theory it could be very
% small because we will walk aways into the skeleton.
graph = assemble_connections(C, startPoints,I, minDist/2, nodeClass);

% remove redundant braches and converte connections format
disp('simplifying graph...');
graph = simplify_graph(graph);


%  TODO : fix it! (for now you cant draw serir arrows)
%
% account for the situation where there are two or more arrows in serie. It
% inserts an type 0 node in the middle
%disp('looking for direct serir nodes...');
% minDist here do not need to be big enough. In theory it could be very
% small because we will walk aways into the skeleton.
%graph = correct_serie_linked_branches(graph, I, minDist/2);

% detect direction of each arrow node
disp('identifying direction of nodes...');
graph = get_directions(graph, I, minDist);

% Generate a graph of the kind
%   G.C (centers)
%   G.startPoints (starting points from each node)
%   G.nodeClass (type of the node (0, 1, 3, 4)
%   G.start (index of the start node)
%   G.stop (index of the stop node)
%   G.connections = [depart_1 depart_2 depart_3 ... depart_n ];
%                   [arrive_1 arrive_2 arrive_3 ... arrive_n ];
%      where depart_i and arrive_i represent a connection from node
%      depart_i to node arrive_i 
%
%   TODO: cluster type 0 nodes (bifurcations that are, eventually connected
%   whitout an arrow. They will be considered the same node.
disp('consolidatin graph...');
G = consolidate_graph(graph);




%to use in Mason?s formula

% get direct paths 
disp('identifying direct paths...');
Pdir = get_direct_paths(G);
%Pdir = {[1 2]};

% get loop paths 
disp('identifying loops...');
Ploop = get_loop_paths(G);
%Ploop = {};


% transfer functions (direct and loops)
%    only the arrow nodes (representing the transfer functions)
disp('Computing transfer functions for direct and loop paths...');
Tdir = get_transfer_functions(Pdir, G);
Tloop = get_transfer_functions(Ploop, G);


% get real names and values of the TF
disp('asking user about values of transfer functions...');
gs = simple(get_values_for_nodes(G1, I, G));



% MASON FORMULA!!!!!!!!!
disp('Applying mason?s formula...');
T = mason_formula(Tdir, Tloop, G, gs);




close('all');

disp('Displaying results...');
% cosmetic presentation...
figure('menubar','figure','toolbar','none');
axes('position',[0.01 0.01 0.98 0.9]);
imshow(uint8(Img));
colormap('gray');
title('ORIGINAL IMAGE (FROM THE CAMERA)','fontweight','bold');

figure('menubar','figure','toolbar','none');
axes('position',[0.01 0.01 0.98 0.9]);
imagesc(uint8(cat(3,G1,G1,G1).*Img+cat(3,128*I,128*I,I)+cat(3,128*~G1,128*~G1,128*~G1)));
colormap('gray');
hold('on');
t = 0:0.1:(2*pi+0.1);

for i=1:length(graph.connections)
    line([graph.C(2,graph.connections(i,1)) graph.C(2,graph.connections(i,2))] ,[graph.C(1,graph.connections(i,1)) graph.C(1,graph.connections(i,2))],'linewidth',3);
end
plot(graph.C(2,:),graph.C(1,:),'ko','markersize',6,'linewidth',4);

for i=1:length(graph.C)
    switch (graph.nodeClass(i))
        case 0
            color = [1 1 1];
        case 1
            color = [0 1 0];
        case 3
            color = [1 1 0];
        case 4
            color = [0 1 1];
    end
    line(minDist*cos(t)+graph.C(2,i),minDist*sin(t)+graph.C(1,i),'color',color*0.2,'linestyle',':');
    line(minDist*cos(t)/2+graph.C(2,i),minDist*sin(t)/2+graph.C(1,i),'color',color);
    
    if (graph.nodeClass(i)==1)
        if (graph.directions(i))
            plot(graph.startPoints{i}(2,1),graph.startPoints{i}(1,1),'o','color',[1 0 0],'markersize',2,'linewidth',3);
            plot(graph.startPoints{i}(2,2),graph.startPoints{i}(1,2),'o','color',[1 1 1],'markersize',2,'linewidth',3);
        else
            plot(graph.startPoints{i}(2,1),graph.startPoints{i}(1,1),'o','color',[1 1 1],'markersize',2,'linewidth',3);
            plot(graph.startPoints{i}(2,2),graph.startPoints{i}(1,2),'o','color',[1 0 0],'markersize',2,'linewidth',3);
        end            
    end

end

H = size(Img,2);

for i=1:length(graph.nodeClass)
    if (graph.nodeClass(i)==1)
        color = 'c';
    else
        color = 'w';
    end
    text(graph.C(2,i),graph.C(1,i),['g' num2str(i)],'backgroundcolor',color);
end
title('PROCESSED IMAGE','fontweight','bold');



% plot direct paths
figure('menubar','figure','toolbar','none');
N = length(Pdir);
for i=1:N
    if N==1
        axes('position',[0.01 0.01 0.98 0.9]);
    else
%        subplot(2,1+fix((N-0.01)/2),i);
        subplot(1,N,i);
    end
    imagesc(uint8(Img));
    axis('off');
    colormap('gray');
    
    % whole graph
    for j=1:length(graph.connections)
        line([graph.C(2,graph.connections(j,1)) graph.C(2,graph.connections(j,2))] ,[graph.C(1,graph.connections(j,1)) graph.C(1,graph.connections(j,2))],'linewidth',3,'color','b');
    end
    
    
    L = length(Pdir{i});
    for j=1:(L-1)
        c1 = G.C(:,Pdir{i}(j));
        c2 = G.C(:,Pdir{i}(j+1));

        line( [c1(2) c2(2)], [c1(1) c2(1)] ,'linewidth',3,'color','r');
    end
end


% plot loop paths
figure('menubar','figure','toolbar','none');
N = length(Ploop);
for i=1:N
    if N==1
        axes('position',[0.01 0.01 0.98 0.9]);
    else
%        subplot(2,1+fix((N-0.01)/2),i);
        subplot(1,N,i);
    end
    imagesc(uint8(Img));
    axis('off');
    colormap('gray');
    L = length(Ploop{i});
    
    % whole graph
    for j=1:length(graph.connections)
        line([graph.C(2,graph.connections(j,1)) graph.C(2,graph.connections(j,2))] ,[graph.C(1,graph.connections(j,1)) graph.C(1,graph.connections(j,2))],'linewidth',3,'color','b');
    end
    
    
    for j=1:(L-1)
        c1 = G.C(:,Ploop{i}(j));
        c2 = G.C(:,Ploop{i}(j+1));

        line( [c1(2) c2(2)], [c1(1) c2(1)] ,'linewidth',3,'color','r');
    end
end


F = figure('menubar','figure','toolbar','none');
pos = get(F,'position');
pos(1) = 0;
pos(2) = 0;
axes('position',pos);
H = text(0.05,0.5,['$' latex(T) '$'],'Interpreter','latex','fontsize',20,'VerticalAlignment','bottom');
set(H,'units','pixels');
set(H,'position',[20 20 0]);
ex = get(H,'Extent');
set(F,'position',[50 50 ex(3)+20 ex(4)+20])
axis('off');