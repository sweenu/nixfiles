[
  {
    match.namespace = "selection";
    animation = "fade";
  } # slurp
  {
    match.namespace = "wayfreeze";
    animation = "fade";
  }

  {
    match.namespace = "launcher";
    animation = "popin 80%";
    blur = true;
  }

  ## Shell ##
  {
    match.namespace = "^(dms)$";
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
    match.namespace = "dms:(color-picker|clipboard|spotlight|settings)";
    blur = true;
    dim_around = true;
  }
]
