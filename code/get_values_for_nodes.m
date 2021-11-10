function gs = get_values_for_nodes(G1, I, G)

   % takes the graph and the transfer function, shows a window to he user
   % asking the values for each TF and computes the final TF
   %
   %  G1 - segmented image
   %  I - skeletized image
   %  G - computed graph
   %
   %  returns an array contaning the transfer functions

    close('all');
    figure('menubar','none','toolbar','none');
    imagesc(G1+I);
    colormap('gray');
    hold('on');
    for i=1:length(G.nodeClass)
        text(G.C(2,i),G.C(1,i),num2str(i),'backgroundcolor','c');
    end

    gs = sym(zeros(1,length(G.nodeClass)));
    
    N = sum(G.nodeClass==1);

    H = figure('menubar','none','toolbar','none','position',[100 100 300 40+30*N],'userdata',1);

    count = 0;
    bt = [];
    for i=1:length(G.nodeClass)
        if G.nodeClass(i)==1
            count = count+1;
            uicontrol('style','text','string',['g' num2str(i) '= '],'units','pixels','position',[10 10+30*(count-1) 50 20]);
            bt = [bt uicontrol('style','edit','string','s','units','pixels','position',[70 10+30*(count-1) 210 20])];
        end
    end
    
    uicontrol('style','pushbutton','string','ok','units','pixels','position',[100 10+30*N 100 25],'callback','set(gcf,''userdata'',0)');

    a = 1;
    while a
        drawnow();
        a = get(H,'userdata');
    end
    
    count = 0;
    for i=1:length(G.nodeClass)
        if G.nodeClass(i)==1
            count = count+1;
            t = get(bt(count),'string');
 %           eval(['g' num2str(i) ' = sym( ''' t ''' );']);
            gs(i) = sym(t);
        end
    end

%    gs = eval(T);
    
end
