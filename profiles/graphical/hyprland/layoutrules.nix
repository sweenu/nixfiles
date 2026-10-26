[
  {
    match.namespace = "selection";
    animation = "fade";
  } # slurp

  ## Shell ##
  # dms:frame is the bar
  {
    match.namespace = "^dms:frame$";
    no_anim = true;
  }
  {
    match.namespace = "dms:control-center";
    animation = "slide right";
  }
  {
    match.namespace = "dms:workspace-overview";
    animation = "slide top";
  }

  {
    match.namespace = "dms:(color-picker|clipboard|spotlight)";
    blur = true;
    dim_around = true;
  }
]
