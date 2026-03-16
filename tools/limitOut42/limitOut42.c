/**
 * limitOut42.c
 *
 * by mofrim
 *
 * A minimal utility for in-script usage to produce docker-cli-like row-wrapped
 * output for subcommands that produce a lot of output.
 * Technical detail: reads input from fd 42 in order to leave stdin untouched
 * for proper detection of cursor position.
 *
 * Usage:
 * ./limitOut42 42< <(you command line)
 *
 *
 *
 * QUESTION:
 * maybe it is a better approach to give the command to be limited as a
 * cmdline arg and then fork it in here, dup2 the stdout here and so on... on
 * the other this might lead to a more bloated program here as there would be
 * quite some error checking to be done.
 *
 * TODO: refactor, extract functions
 *
 * TODO: clarify / check for compatibility
 *
 * TODO: implement more tests
 */

#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

/* ----------------------------=[ global vars ]=---------------------------- */

static struct termios g_oldTermios, g_newTermios;
static int            g_exitLoop;

/* ANSI Sequences
 * ==============
 *
 * - Move Cursor To (x, y) - Upper Left Corner is (1, 1) Paremeters: X Y
 *
 *		printf "\x1B[Y;XH"
 *
 * 	- Hide Cursor
 *
 *		printf "\x1B[?25l"
 *
 *	- Show Cursor
 *
 *		printf "\x1B[?25h"
 *
 */

/* ------------=[ prototypes. implementations after main func ]=------------ */

void freeAndNull(char **ptr);
int  moveCursor(int x, int y);
void configure_terminal();
void reset_terminal();
void signal_handler(__attribute__((unused)) int signum);
int  get_pos(int *y, int *x);

/* ------------------------------=[ the main ]=------------------------------ */

int main(int ac, char **av)
{
  if (ac > 2)
  {
    printf("usage: %s [numOfLines: int = 5] 42< <(you command line)", av[0]);
    return 0;
  }

  bool passThrough = false;

  int numOfLines = 5;
  if (ac == 2)
    numOfLines = atoi(av[1]);
  if (numOfLines <= 0)
    passThrough = true;

  /* check terminal size and compare to specified numOfLines for output
   * scrolling */
  struct winsize w;
  ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
  if (numOfLines > w.ws_row - 1)
  {
    fprintf(stderr, "numOfLines = %d bigger then terminal size (%dx%d)",
        numOfLines, w.ws_row, w.ws_col);
    passThrough = true;
  }

  /* get current cursor position */
  int row, col;
  if (get_pos(&row, &col) != 0)
  {
    fprintf(stderr,
        "Failed to get cursor position.\nFalling back to simple pass-through.");
    passThrough = true;
  }

  char    **lines       = NULL;
  const int linesMaxIdx = numOfLines - 1;
  if (!passThrough)
  {
    lines = (char **)malloc(sizeof(char *) * numOfLines);
    for (int i = 0; i < numOfLines; i++)
      lines[i] = NULL;
  }

  configure_terminal();

  signal(SIGINT, signal_handler);

  FILE *input42;
  if ((input42 = fdopen(42, "r")) == NULL)
  {
    fprintf(stderr, "could not open fd 42\n");
    return 1;
  }

  int    i    = 0;
  char  *line = NULL;
  size_t n    = 0;
  while (getline(&line, &n, input42) > 0 && !g_exitLoop)
  {
    if (passThrough)
    {
      printf("%s", line);
      freeAndNull(&line);
    }
    else
    {
      if (i < numOfLines)
      {
        printf("%s", line);
        lines[i] = strdup(line);
        freeAndNull(&line);
      }
      else
      {
        free(lines[0]);
        for (int j = 0; j < linesMaxIdx - 1; j++)
          lines[j] = lines[j + 1];
        if (numOfLines != 1)
        {
          lines[linesMaxIdx - 1] = strdup(lines[linesMaxIdx]);
          free(lines[linesMaxIdx]);
        }
        lines[linesMaxIdx] = strdup(line);
        freeAndNull(&line);
        moveCursor(1, row - numOfLines);
        for (int j = 0; j < numOfLines; j++)
          printf("%s", lines[j]);
      }
      i++;
      usleep(150000);
    }
  }

  for (int j = 0; j < numOfLines; j++)
    if (lines[j] != NULL)
      free(lines[j]);
  free(lines);
  if (line != NULL)
    free(line);
  fclose(input42);

  return 0;
}

/* -------------------------------=[ utils ]=------------------------------- */

void freeAndNull(char **ptr)
{
  free(*ptr);
  *ptr = NULL;
}

int moveCursor(int x, int y)
{
  return printf("\x1B[%d;%dH", y, x);
}

/* not used, but keep for possible future features.. */
void clearScreen(void)
{
  printf("\x1B[2J");
}

/* ---------------------------=[ the real stuff ]=--------------------------- */

void configure_terminal()
{
  tcgetattr(STDIN_FILENO, &g_oldTermios);
  g_newTermios = g_oldTermios; // save it to be able to reset on exit

  g_newTermios.c_lflag &=
      ~(ICANON | ECHO); // turn off echo + non-canonical mode
  g_newTermios.c_cc[VMIN]  = 0;
  g_newTermios.c_cc[VTIME] = 0;

  tcsetattr(STDIN_FILENO, TCSANOW, &g_newTermios);

  printf("\x1B[?25l"); // hide cursor
  printf("\x1B[37m");  // set color to grey
  setvbuf(stdout, NULL, _IONBF, 0);
  atexit(reset_terminal);
}

void reset_terminal()
{
  printf("\x1B[m");    // reset color changes
  printf("\x1B[?25h"); // show cursor
  fflush(stdout);
  tcsetattr(STDIN_FILENO, TCSANOW, &g_oldTermios);
  setvbuf(stdout, NULL, _IOLBF, 0);
}

void signal_handler(__attribute__((unused)) int signum)
{
  g_exitLoop = 1;
}

int get_pos(int *y, int *x)
{
  char buf[30] = {0};
  int  ret, i, pow;
  char ch;

  *y = 0;
  *x = 0;

  struct termios term, restore;

  tcgetattr(0, &term);
  tcgetattr(0, &restore);
  term.c_lflag &= ~(ICANON | ECHO);
  tcsetattr(0, TCSANOW, &term);

  if (write(1, "\033[6n", 4) == -1)
  {
    tcsetattr(0, TCSANOW, &restore);
    return 1;
  }

  for (i = 0, ch = 0; ch != 'R'; i++)
  {
    ret = read(0, &ch, 1);
    if (!ret)
    {
      tcsetattr(0, TCSANOW, &restore);
      return 1;
    }
    buf[i] = ch;
  }

  if (i < 2)
  {
    tcsetattr(0, TCSANOW, &restore);
    return (1);
  }

  for (i -= 2, pow = 1; buf[i] != ';'; i--, pow *= 10)
    *x = *x + (buf[i] - '0') * pow;
  for (i--, pow = 1; buf[i] != '['; i--, pow *= 10)
    *y = *y + (buf[i] - '0') * pow;

  tcsetattr(0, TCSANOW, &restore);
  return 0;
}
