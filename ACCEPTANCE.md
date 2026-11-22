# Form validation: acceptance criteria

1. Given no score is selected, when I tap Save entry, then the message "Choose a score from 1 to 10" appears and nothing is added to the history.
2. Given a score is selected and a note has 2001 characters, when I tap Save entry, then an error message appears explaining the note is too long and nothing is added to the history.
3. Given a score is selected and a note has 2000 characters, when I tap Save entry, then the entry is added to the top of the history and the form clears.
4. Given a score is selected and the note is empty, when I tap Save entry, then the entry is added to the top of the history with no note and the form clears.