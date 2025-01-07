#!/bin/sh

# -v be talkative
# -i interface; can be a '*' which denotes all interfaces which are in UP state

# -a iovector pointer modifiers, 4 elements; -1 forces NULL pointer
# -b iovector length modifiers, 4 elements;

# -c header msg_name modifier; -1 forces NULL pointer
# -d header msg_namelen modifier

# -e header msg_iov modifier; -1 forces NULL pointer
# -f header msg_iovlen

# -s sendmsg() passed pointer moidifier; -1 forces NULL pointer


# all modifiers example:
/usr/bin/pon_socket_tester -v -a '1,0,0,0' -b '2,0,0,0' -c -3 -d 4 -e -1 -f 5 -s 6 -r < /etc/pon-sock-test.msg

# iovector pointers spoiled - forced NULL (-1 is automatically shifted through all 4 iovector pointers)
/usr/bin/pon_socket_tester -a '-1, 0, 0, 0'

# iovector pointers spoiled - increased by 10 added (incrementation is automatically shifted through all 4 iovector pointers in 4 passes)
/usr/bin/pon_socket_tester -a '10, 0, 0, 0'

# iovector lengths spoiled - increased by 5 (5 is automatically shifted through all 4 iovector length in 4 passes)
/usr/bin/pon_socket_tester -b '5, 0, 0, 0'

# header msg_iov pointer spoiled - increased by 10
/usr/bin/pon_socket_tester -e 10
# header msg_iov pointer spoiled - forced to be NULL by a special value -1
/usr/bin/pon_socket_tester -e -1

# header msg_iovlen spoiled (number of iovector elements) - increased by 2
/usr/bin/pon_socket_tester -f 2

# sendmsg() pointer spoiled  - increased by 20
/usr/bin/pon_socket_tester -s 20
# NULL pointer passed to sendmsg() - forced to be NULL by a special value -1
# and another interface
/usr/bin/pon_socket_tester -i eth0_1 -s -1
# ...and all interfaces which are in UP state
/usr/bin/pon_socket_tester -i '*' -s -1

