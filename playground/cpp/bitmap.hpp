#pragma once

class Bitmap {
 private:
  int btmp_bytes_len;
  unsigned char *bits;

 public:
  void bitmap_init();
  bool bitmap_scan_test(int bit_index);
  int bitmap_allocate(int cnt);
  void bitmap_set(int bit_index, unsigned char v);
};
