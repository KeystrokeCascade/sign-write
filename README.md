# Sign Write
PowerShell script for controlling serial POS LED signs, based on and configured for C2202-PD.

Assumes a sign with 2 rows and a length of 40 characters in total, character length can be easily changed however reconfiguring for more rows might take a bit more work.

---

```
  help                   Display this message.  Aliases: h, ?
  write [-b] [message]   Displays a message on the screen, leave blank to clear screen.  Aliases: w
      -b                 Disables automatic line breaking
  center [-b] [message]  Displays a centered message on the screen.  Aliases: c
      -b                 Disables automatic line breaking
  scroll [-s] [message]  Scrolls a message over the screen, press any key to interrupt.  Aliases: s
      -s [speed]         Speed of scrolling, in milliseconds
  page [-bsc][message]   Displays a message over several 'pages' for longer strings, press any key to interrupt.  Aliases: p
      -b                 Disables automatic line breaking
      -s [speed]         Speed of pages, in milliseconds
      -c                 Centers the text on each page
  clear                  Clears the terminal.  Aliases: cls
  exit                   Leave the session.  Aliases: quit, q

  Examples:
  write foo bar
  w -b foo bar
  scroll -s 400 foo bar
  page -sc 600 foo bar
  ```

Note: This was before I knew the form feed special character (\`f) could be used to both clear the screen and reset the cursor and I'm lazy.
