#include <string.h>
#include "GKSip.h"


void pjstr_to_char(char* dst, const int dst_len, const pj_str_t* src)
{
    int len;
    
    len = dst_len > src->slen ? src->slen : dst_len;
    
    strncpy(dst, src->ptr, len);
}
