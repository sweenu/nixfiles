final: prev: {
  himalaya = prev.himalaya.override {
    withFeatures = [
      "notmuch"
      "imap"
      "maildir"
      "smtp"
    ];
  };
}
