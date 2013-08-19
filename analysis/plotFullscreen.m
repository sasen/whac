%function GetHits(s1,s2,ExpNum,tr)
% GetHits.m  Plot mole intervals against Z values from tracker
% GetHits(s1,s2,ExpNum,tr) -- doesn't work for Fullscreen!

% if nargin==0
%   s1 = 'jlp'; s2 = 'ss'; ExpNum = 3; tr=4;
%   % s1 = '35'; s2 = 'sasen'; ExpNum = 1; tr=39;
% end

%g = LoadGame('att','jcc',1.01,1);
g = LoadGame('m7r','ss',1,1);

clr = g.TargetColors/255;
tgtDur = g.TargetPresTime/1000;  % target duration in s
trackt = g.TrackList{3}/240;  % time in s
zspec = {'r.--'; 'b.--'};
hitspec = {'rv'; 'b^'};
slotsize = size(g.LocationListX);  % size of unflattened mole info matrices, to retrieve mole slot

figure;
hold on
%title(['\fontsize{16}' g.pname1 ' vs ' g.pname2 ' trial ' num2str(g.TrlNum)])
xlabel('\fontsize{14}time (s)')
ylabel('\fontsize{14}height (in)')

for pl=[1 2]
    mole = g.mole{1};
    plot(trackt,g.TrackList{pl}(3,:),zspec{pl})

    lo=0; hi=g.TrialLength;  % bounds in s
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
        plot([mOn;mOff], [slot;slot]/20, 'LineWidth',2, 'Color',clr(type,:));  % plot mole-colored line in the right slot
	% if it was hit, mark which player hit it
	if mole(6,m)  % 1=p1, 2=p2
	  plot(mole(7,m),slot/20,hitspec{mole(6,m)},'MarkerSize',10);
	end
    end
end
axis tight