#!/usr/bin/expect -f

set timeout -1

cd sts
spawn ./assess 1212210

expect "*G E*\r"
send -- "0\r"
 
expect "*Prescribed*"
send -- "../sp800test.log\r"

expect "*S T*\r"
send -- "1\r"

expect "*P a*\r"
send -- "0\r"

expect "*bitstreams*"
send -- "64\r"

expect "*input mode*"
send -- "0\r"

expect eof
