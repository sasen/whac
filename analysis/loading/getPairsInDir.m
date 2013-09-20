function Subjects = getPairsInDir(d)
% function Subjects = getPairsInDir(d)
% d (str) = directory name, fullpath
% Subjects{1} (cell) = subject1 names
% Subjects{2} (cell) = subject2 names
% Subjects{3} (cell) = both names as s1_s2

%% errorcheck input
assert(exist(d,'dir')==7, '%s: Cannot find directory %s.',mfilename,d);

%% go through this directory and get subjectdirs
D = dir(d);
D = D([D.isdir]);   % remove non-directories
x = 1;
for i = 1:length(D)
  namestr = D(i).name;
  if namestr(1)~='.'  % ignore '.' and '..'
    [s1, s2] = strtok(namestr,'_');
    Subjects{1}{x} = s1;
    Subjects{2}{x} = s2(2:end);  % exclude '_'
    Subjects{3}{x} = namestr;
    x = x+1;
  end
end
