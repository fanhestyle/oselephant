int main(void)
{
    asm(" \
    movb $'G', %gs:(498) \
    ");

    while(1);
    return 0;
}