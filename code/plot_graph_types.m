function plot_graph_types(I, graph)

imagesc(I);

hold('on'); 

for i=1:length(graph.nodeClass)
    
    switch (graph.nodeClass(i))
        case 0
            color = 'r.';
        case 1
            color = 'g.';
        case 2
            color = 'b.';
        case 3
            color = 'yo';
        case 4
            color = 'co';
    end
    
    plot(graph.C(2,i),graph.C(1,i),color);
    H = text(graph.C(2,i),graph.C(1,i), num2str(i));
    set(H,'FontSize',20);
end


end