{
  services.tsidp = {
    enable = true;
    settings = {
      # debugAllRequests = true;
      useLocalTailscaled = false; # otherwise will conflict with ts serve
    };
  };
}
