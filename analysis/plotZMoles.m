function plotZMoles(g)
% Plot mole intervals against Z values from tracker
% function plotZMoles(g)
% g (struct) loaded trial data (from, LoadGame or LoadExpt)

lo=0; hi=g.TrialLength;  % bounds in s
clr = g.TargetColors/255;
tgtDur = g.TargetPresTime/1000;  % target duration in s
trackt = g.TrackList{3}/240;  % time in s
zspec = {'r.--'; 'b.--'};
hitspec = {'rv'; 'b^'};
slotsize = [g.MaxTargetsOnScreen g.nTargetOnsets];

figure;
if g.ExpNum < 3   %% 1 & 2 have one game, fullscreen or mirrored halves
  game=[1 1];
else  % 3 & 4 have two games, player # == game #
  game=[1 2];
end

% setup subplots (1 for full/mirrored, 2 for split)
for i=[1 2]
  gg=game(i);
  ax(i) = subplot(game(end),1,gg);
end

for pl=[1 2]
    mole = g.mole{game(pl)};
    hh(pl) = plot(ax(game(pl)),trackt,g.TrackList{pl}(3,:),zspec{pl});
    hold(ax(game(pl)),'on');
    mIdx = find((mole(2,:) >lo) & (mole(2,:) < hi));  % select moles in bounds

    for m=mIdx
        mOn = mole(2,m);
        if mole(7,m)
            mOff=mole(7,m);
        else
            mOff=mOn+tgtDur;
        end
        type = mole(3,m);
	[slot, ~] = ind2sub(slotsize, mole(1,m));  % which of the 8 currently-appearing moles it is
        plot(ax(game(pl)),[mOn;mOff], [slot;slot]/20, 'LineWidth',2, 'Color',clr(type,:));  % plot mole-colored line in the right slot
	% if it was hit, mark which player hit it
	if mole(6,m)  % 1=p1, 2=p2
	  plot(ax(game(pl)),mole(7,m),slot/20,hitspec{mole(6,m)},'MarkerSize',10);
	end
    end
    axis(ax(game(pl)),'tight');
    ylabel(ax(game(pl)),'\fontsize{14}height (in)');
end
title(ax(1),['\fontsize{16}' g.pname1 ' vs ' g.pname2 ' trial ' num2str(g.TrlNum) ' ']);
xlabel(ax(end),'\fontsize{14}time (s)');
legend(hh,'player1','player2');

