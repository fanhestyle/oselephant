#include "bitmap.hpp"

#include <bits/stdc++.h>
using namespace std;

void Bitmap::bitmap_init() { memset(bits, 0, btmp_bytes_len); }

bool Bitmap::bitmap_scan_test(int bit_index) {
  int byte_idx = bit_index / 8;
  int byte_odd = bit_index % 8;
  return bits[byte_idx] & (1 << byte_odd);
}

int Bitmap::bitmap_allocate(int cnt) {
    
}





void Bitmap::bitmap_set(int bit_index, unsigned char v) {
  int byte_idx = bit_index / 8;
  int byte_odd = bit_index % 8;
  bits[byte_idx] |= (1 << byte_odd);
}
