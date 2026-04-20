#ifdef _WIN32
#include <windows.h>
int main(void) {
    Sleep(INFINITE);
    return 0;
}
#else
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
static void quit(int sig) { (void)sig; _exit(0); }
int main(void) {
    signal(SIGTERM, quit);
    signal(SIGINT, quit);
    pause();
    return 0;
}
#endif
