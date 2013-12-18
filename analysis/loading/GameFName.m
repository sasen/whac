function [fname, nMats] = GameFName(s1,s2,e,t)
% Construct filename for a single trial/game from subject IDs, exp #, trial #
%   s1 (string) = playerID1
%   s1 (string) = playerID2
%   e (num/str) = experiment number, 
%   t (integer) = trial number
%   fname (string)= filename (including relative path) to game's .mat
%   nMats (int) = # of matfiles found in relevant directory (optional)

dirbase = ['../../WAM/'];  % for compatibility with git & dropbox users
pairname = [s1 '_' s2];

e = num2str(e);
if e=='1'
    gameType='RunFullscreen';
    matdir = [dirbase gameType '/HonestConfederate/' pairname '/'];
    if (exist(matdir,'dir')~=7)
      matdir = [dirbase gameType '/SubjectVsSubject/' pairname '/'];
      if (exist(matdir,'dir')~=7)
	matdir = [dirbase gameType '/DeceptiveConfederate/' pairname '/'];
      end
    end
elseif e=='1.01'
    gameType='RunFullscreen';
    matdir = [dirbase gameType '/NaberSubjVsSubj/' pairname '/'];
elseif e=='2'
    gameType='RunMirrored';
    matdir=[dirbase gameType '/' pairname '/'];
elseif e=='3'
    gameType='RunSplitgame';
    matdir=[dirbase gameType '/' pairname '/'];
elseif e=='4'
    gameType='RunDistractors';
    matdir=[dirbase gameType '/' pairname '/'];
end
assert(exist(matdir,'dir')==7, '%s: Cannot find directory %s.',mfilename,matdir);

%% if nargout > 1 ?
dirContents = what(matdir);
nMats = size(dirContents.mat,1);
% matNames = dirContents.mat; %%% Could use to assert presence of fname

fname = [matdir pairname '_t' num2str(t) '_e' e '.mat'];

