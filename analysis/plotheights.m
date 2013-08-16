function plotheights(x,y1,y2,thisDelay)
% function plotheights(x,y1,y2,thisDelay)
%    x = time in s or time indices (int/float)
%    y1 & y2 = height trajectories of a trial (z data, float)
%    thisDelay = delay interval in seconds, (float)
% This is mostly from the project waterloo people at KCL! 
% Used to be called update2; modded to animate trajectories.
 
    if nargin == 4
        DELAY = thisDelay;
    else
        DELAY = 0.01;
	if nargin==0
	  x = linspace(-pi*4, pi*4, 50);
	  y1 = cos(x);	  
	  y2 = sin(x);	  
	end
    end
 
    % Set up and create some data
    f = GXFigure();
    set(gcf, 'Units','normalized', 'Position',[0.3 0.3 0.4 0.4], 'Name','Trajectory Heights');
     
    % Now  the plot
    gr1 = subplot(f,1,1,1);
    p1 = line(gxgca, [], [], 'LineSpec', '-.g');
    p2 = line(gxgca, [], [], 'LineSpec', '-.b');
    miny = min([y1(:); y2(:)]);
    rangey = range([y1(:); y2(:)]);
    gr1.getObject().getView().setAxesBounds(min(x),miny,range(x),rangey);

    % We'll draw 2 points only in each timer call below (2 points needed for interconnecting line)
    % This plot will therefore show only these points when the normal paint mechanism is
    % used unless all the data are added at the end: which the timer callback below does
    p1.getObject().setXData(x(1:2));
    p1.getObject().setYData(y1(1:2));
    p2.getObject().setXData(x(1:2));
    p2.getObject().setYData(y2(1:2));
 
    p1.getObject().getParentGraph().setLeftAxisPainted(true);
    p1.getObject().getParentGraph().setBottomAxisPainted(true);
    p1.getObject().getParentGraph().setInnerAxisPainted(true);
 
    p1container = p1.getObject().getParentGraph().getGraphContainer();
    p1container.repaint();
    p2container = p2.getObject().getParentGraph().getGraphContainer();
    p2container.repaint();
    
    drawnow();
%     writer=GIFWriter('sine.gif',p1container,DELAY,1);
%     writer.add();

    t = timer('ExecutionMode','fixedSpacing', 'Period',DELAY, 'TimerFcn', {@localTimer, p1.getObject(), p2.getObject(), x, y1, y2});
%    t = timer('ExecutionMode','fixedSpacing', 'Period',DELAY, 'TimerFcn', {@localTimer, p1.getObject(), x, y, writer.Object});
    start(t);

    function localTimer(t, EventData, p1, p2, x, y1, y2)
%    function localTimer(t, EventData, p1, x, y, wr)
        k = get(t,'TasksExecuted');
        if k > numel(x)
            % Finished
            stop(t);
            p1.setXData(x);
            p1.setYData(y1);
            p1.plotRedraw();
            p2.setXData(x);
            p2.setYData(y2);
            p2.plotRedraw();
        elseif k > 1
            % Add 2 new data points to the plot
            p1.setXData(x(k-1:k));
            p1.setYData(y1(k-1:k));
            p1.plotRedraw();
            p2.setXData(x(k-1:k));
            p2.setYData(y2(k-1:k));
            p2.plotRedraw();
%	    wr.add();
        end
    end  % localTimer

%     writer.add();
%     writer.close(); 
end  % update2