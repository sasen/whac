function plotgame(x1,y1,z1,x2,y2,z2,thisDelay)
% function plotgame(x1,y1,z1,x2,y2,z2,thisDelay)
%   Test mode = no arguments (plots some sinewaves)

    if nargin == 5
        DELAY = thisDelay;
    else
        DELAY = 0.01;
	if nargin==0
	  x1 = linspace(-pi*4, pi*4, 50);
	  x2 = linspace(-pi*2, pi*6, 50);
	  y1 = cos(x1);	  
	  y2 = sin(x2);	  
	  z1 = cos(2*x1);	  
	  z2 = sin(3*x2);	  
	end
    end
 
    % Set up and create some data
    f = GXFigure();
    set(gcf, 'Units','normalized', 'Position',[0 0 0.8 0.6], 'Name','3d Trajectories');
     
    % Now  the plot
    gr1 = subplot(f,2,1,1);
    p1 = line(gxgca, [], [], 'LineSpec', '-.g');
    p2 = line(gxgca, [], [], 'LineSpec', '-.b');
    gr2 = subplot(f,2,1,2);
    pz1 = line(gxgca, [], [], 'LineSpec', '-.g');
    pz2 = line(gxgca, [], [], 'LineSpec', '-.b');

    minx = min([x1(:); x2(:)]);
    rangex = range([x1(:); x2(:)]);
    miny = min([y1(:); y2(:)]);
    rangey = range([y1(:); y2(:)]);
    gr1.getObject().getView().setAxesBounds(minx,miny,rangex,rangey);
    minz = min([z1(:); z2(:)]);
    rangez = range([z1(:); z2(:)]);
    gr2.getObject().getView().setAxesBounds(1,minz,length(z1),rangez);

    % We'll draw 2 points only in each timer call below (2 points needed for interconnecting line)
    % This plot will therefore show only these points when the normal paint mechanism is
    % used unless all the data are added at the end: which the timer callback below does
    p1.getObject().setXData(x1(1:2));
    p1.getObject().setYData(y1(1:2));
    p2.getObject().setXData(x2(1:2));
    p2.getObject().setYData(y2(1:2));

    pz1.getObject().setXData([1:2]);
    pz1.getObject().setYData(z1(1:2));
    pz2.getObject().setXData([1:2]);
    pz2.getObject().setYData(z2(1:2));
 
    p1.getObject().getParentGraph().setLeftAxisPainted(true);
    p1.getObject().getParentGraph().setBottomAxisPainted(true);
    p1.getObject().getParentGraph().setInnerAxisPainted(true);
    pz1.getObject().getParentGraph().setLeftAxisPainted(true);
    pz1.getObject().getParentGraph().setBottomAxisPainted(true);
    pz1.getObject().getParentGraph().setInnerAxisPainted(true);
 
    p1container = p1.getObject().getParentGraph().getGraphContainer();
    p1container.repaint();
    
    drawnow();
%     writer=GIFWriter('sine.gif',p1container,DELAY,1);
%     writer.add();

    t = timer('ExecutionMode','fixedSpacing', 'Period',DELAY, 'TimerFcn', {@localTimer, p1.getObject(), p2.getObject(), pz1.getObject(), pz2.getObject(), x1, y1, z1, x2, y2, z2});
    start(t);

    function localTimer(t, EventData, p1, p2, pz1, pz2, x1, y1, z1, x2, y2, z2)
        k = get(t,'TasksExecuted');
        if k > numel(x1)
            % Finished
            stop(t);
            p1.setXData(x1);
            p1.setYData(y1);
            p1.plotRedraw();
            p2.setXData(x2);
            p2.setYData(y2);
            p2.plotRedraw();
	    pz1.setXData([1:numel(z1)]);
	    pz1.setYData(z1);
            pz1.plotRedraw();
	    pz2.setXData([1:numel(z2)]);
	    pz2.setYData(z2);
            pz2.plotRedraw();
        elseif k > 1
            % Add 2 new data points to the plot
            p1.setXData(x1(k-1:k));
            p1.setYData(y1(k-1:k));
            p1.plotRedraw();
            p2.setXData(x2(k-1:k));
            p2.setYData(y2(k-1:k));
            p2.plotRedraw();
	    pz1.setXData([k-1:k]);
	    pz1.setYData(z1(k-1:k));
            pz1.plotRedraw();
	    pz2.setXData([k-1:k]);
	    pz2.setYData(z2(k-1:k));
            pz2.plotRedraw();
%	    wr.add();
        end
    end  % localTimer

%    gr1.getObject().getView().autoScale();

%     writer.add();
%     writer.close(); 
end  % update2