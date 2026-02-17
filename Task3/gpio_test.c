#define GPIO_BASE   0x40000000

#define GPIO_DATA   (*(volatile unsigned int*)(GPIO_BASE + 0x00))
#define GPIO_DIR    (*(volatile unsigned int*)(GPIO_BASE + 0x04))
#define GPIO_READ   (*(volatile unsigned int*)(GPIO_BASE + 0x08))

int main() {

    GPIO_DIR = 0x0F;        // lower 4 bits output
    GPIO_DATA = 0x05;       // drive pattern

    unsigned int val = GPIO_READ;

    printf("GPIO_READ = 0x%X\n", val);

    while(1);
}
