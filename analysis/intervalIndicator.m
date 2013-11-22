function indicator = intervalIndicator(intervals,howLong)
%function indicator = intervalIndicator(intervals,howLong)

assert(size(intervals,2)==2,'%s: intervals must be a 2-column matrix.',mfilename)
assert(howLong > max(max(intervals)),'%s: howLong must be greater than highest interval index',mfilename)

indicator = zeros(howLong,1);
for j = 1:length(intervals)
  starting = intervals(j,1);
  ending   = intervals(j,2);
  indicator(starting:ending) = ones(ending-starting+1,1);
end
