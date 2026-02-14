[
  {
    context = "vim_mode == insert";
    bindings = {
      "alt-;" = "vim::TemporaryNormal";
      "ctrl-n" = "editor::ShowWordCompletions";
      "ctrl-p" = "editor::ShowWordCompletions";
      "ctrl-r" = "vim::PushRegister";
      "ctrl-v" = [
        "vim::PushLiteral"
        { }
      ];
      "escape" = "vim::NormalBefore";
    };
  }
  {
    context = "(vim_mode == helix_normal || vim_mode == helix_select) && !menu";
    bindings = {
      "%" = "editor::SelectAll";
      "*" = [
        "vim::MoveToNext"
        { partial_word = false; }
      ];
      "," = "vim::HelixKeepNewestSelection";
      "/" = "vim::Search";
      ";" = "vim::HelixCollapseSelection";
      "<" = "vim::Outdent";
      "=" = "vim::AutoIndent";
      ">" = "vim::Indent";
      "`" = "vim::ConvertToLowerCase";
      "a" = "vim::HelixAppend";
      "alt-*" = [
        "vim::MoveToNext"
        { partial_word = true; }
      ];
      "alt-." = "vim::RepeatFind";
      "alt-/" = [
        "vim::Search"
        { backwards = true; }
      ];
      "alt-;" = "vim::OtherEnd";
      "alt-`" = "vim::ChangeCase";
      "alt-b" = [
        "vim::PreviousWordStart"
        { ignore_punctuation = true; }
      ];
      "alt-c" = "vim::HelixSubstituteNoYank";
      "alt-d" = "editor::Delete";
      "alt-e" = [
        "vim::NextWordEnd"
        { ignore_punctuation = true; }
      ];
      "alt-f" = [
        "vim::PushFindBackward"
        {
          after = false;
          multiline = true;
        }
      ];
      "alt-h" = "vim::StartOfLine";
      "alt-j" = "vim::JoinLines";
      "alt-J" = "vim::JoinLines";
      "alt-l" = "vim::EndOfLine";
      "alt-s" = [
        "editor::SplitSelectionIntoLines"
        { keep_selections = true; }
      ];
      "alt-shift-c" = "vim::HelixDuplicateAbove";
      "alt-shift-s" = "editor::SelectLine";
      "alt-t" = [
        "vim::PushFindBackward"
        {
          after = true;
          multiline = true;
        }
      ];
      "alt-w" = [
        "vim::NextWordStart"
        { ignore_punctuation = true; }
      ];
      "alt-x" = "editor::SelectLine";
      "b" = "vim::PreviousWordStart";
      "c" = "vim::HelixSubstitute";
      "ctrl-b" = "vim::PageUp";
      "ctrl-d" = "vim::ScrollDown";
      "ctrl-f" = "vim::PageDown";
      "ctrl-u" = "vim::ScrollUp";
      "d" = "vim::HelixDelete";
      "down" = "vim::Down";
      "e" = "vim::NextWordEnd";
      "end" = "vim::EndOfLine";
      "f" = [
        "vim::PushFindForward"
        {
          before = false;
          multiline = true;
        }
      ];
      "g ." = "vim::HelixGotoLastModification";
      "g b" = "vim::WindowBottom";
      "g c" = "vim::WindowMiddle";
      "g e" = "vim::EndOfDocument";
      "g f" = "editor::OpenSelectedFilename";
      "g g" = "vim::StartOfDocument";
      "g h" = "vim::StartOfLine";
      "g i" = "vim::FirstNonWhitespace";
      "g j" = "vim::EndOfDocument";
      "g k" = "vim::StartOfDocument";
      "g l" = "vim::EndOfLine";
      "g n" = "pane::ActivateNextItem";
      "g p" = "pane::ActivatePreviousItem";
      "g t" = "vim::WindowTop";
      "h" = "vim::WrappingLeft";
      "home" = "vim::StartOfLine";
      "i" = "vim::HelixInsert";
      "j" = "vim::Down";
      "k" = "vim::Up";
      "l" = "vim::WrappingRight";
      "left" = "vim::WrappingLeft";
      "m" = "vim::PushHelixMatch";
      "n" = "vim::HelixSelectNext";
      "o" = "vim::InsertLineBelow";
      "p" = "vim::HelixPaste";
      "pagedown" = "vim::PageDown";
      "pageup" = "vim::PageUp";
      "r" = "vim::PushReplace";
      "right" = "vim::WrappingRight";
      "s" = "vim::HelixSelectRegex";
      "shift-a" = "vim::InsertEndOfLine";
      "shift-c" = "vim::HelixDuplicateBelow";
      "shift-h" = "pane::ActivatePreviousItem";
      "shift-i" = "vim::InsertFirstNonWhitespace";
      "shift-l" = "pane::ActivateNextItem";
      "shift-m" = "vim::Matching";
      "alt-n" = "vim::HelixSelectPrevious";
      "shift-o" = "vim::InsertLineAbove";
      "shift-p" = [
        "vim::HelixPaste"
        { before = true; }
      ];
      "shift-r" = "editor::Paste";
      "shift-u" = "vim::Redo";
      "space a" = "editor::ToggleCodeActions";
      "space c" = "editor::ToggleComments";
      "space d" = "editor::GoToDiagnostic";
      "space f" = "file_finder::Toggle";
      "space h" = "editor::SelectAllMatches";
      "space k" = "editor::Hover";
      "space p" = "editor::Paste";
      "space r" = "editor::Rename";
      "space s" = "outline::Toggle";
      "space shift-s" = "project_symbols::Toggle";
      "space w h" = "workspace::ActivatePaneLeft";
      "space w j" = "workspace::ActivatePaneDown";
      "space w k" = "workspace::ActivatePaneUp";
      "space w l" = "workspace::ActivatePaneRight";
      "space w q" = "pane::CloseActiveItem";
      "space w s" = "pane::SplitRight";
      "space w v" = "pane::SplitDown";
      "space y" = "editor::Copy";
      "t" = [
        "vim::PushFindForward"
        {
          before = true;
          multiline = true;
        }
      ];
      "u" = "vim::Undo";
      "up" = "vim::Up";
      "v b" = "editor::ScrollCursorBottom";
      "v c" = "editor::ScrollCursorCenter";
      "v h" = "vim::ColumnLeft";
      "v j" = "vim::LineDown";
      "v k" = "vim::LineUp";
      "v l" = "vim::ColumnRight";
      "v t" = "editor::ScrollCursorTop";
      "v v" = "editor::ScrollCursorCenter";
      "w" = "vim::NextWordStart";
      "x" = "vim::HelixSelectLine";
      "y" = "vim::HelixYank";
      "~" = "vim::ConvertToUpperCase";
    };
  }
  {
    context = "VimControl && !menu";
    bindings = {
      ":" = "command_palette::Toggle";
      "q" = "vim::ReplayLastRecording";
      "shift-q" = "vim::ToggleRecord";
    };
  }
]
