function [index, pl] = findSubject(name,list)

assert(size(list,2)==3,'%s: list should be cell(1,3), resulting from LoadCond.',mfilename);

search1 = strcmp(name,list{1});
search2 = strcmp(name,list{2});

if sum(search1)==1
  index = find(search1);
  pl = 1;
elseif sum(search2)==1
  index = find(search2);
  pl = 2;
else
  error('%s: name %s not found (or not uniquely found) in list.',mfilename,name);
end