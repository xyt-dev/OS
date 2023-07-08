int main(){
    char *str = "Hello Kernel!";
    char *screen = (char *)0xb8160;
    for(int i = 0; i < 13; i++){
        screen[i*2] = str[i];
        screen[i*2+1] = 0x07;
    }
    while(1);
    return 0;
}
