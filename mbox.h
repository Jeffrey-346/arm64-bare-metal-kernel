extern volatile unsigned int mbox[36];

#define MBOX_REQUEST        0
// channel number for GPU to interpret mailbox request
#define MBOX_CH_PROP        8
// message tags
#define MBOX_TAG_GETSERIAL  0x10004
#define MBOX_TAG_SETCLKRATE 0x38002
#define MBOX_TAG_LAST       0

int mbox_call(unsigned char channel);
