#include <stdlib>
#include <stdio>

int main(int argc, char *argv[]) {
    .for {.set i 0} {$i<5} {.incr i} {
        printf("[.expr 1+$i]\n")
    }
}
