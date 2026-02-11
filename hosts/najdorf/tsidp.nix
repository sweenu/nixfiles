{
  services.tsidp = {
    enable = true;
    settings = {
      useLocalTailscaled = false; # otherwise will conflict with ts serve
    };
  };
}
