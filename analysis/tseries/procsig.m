function x=procsig(x)
  x=x-min(x);
  mux=mean(x);
  x=x/mux;
end
