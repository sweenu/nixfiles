final: prev: {
  himalaya = prev.himalaya.override {
    buildFeatures = [
      "notmuch"
      "imap"
      "maildir"
      "smtp"
    ];
    buildNoDefaultFeatures = true;
  };
}
