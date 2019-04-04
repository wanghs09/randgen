#!/bin/bash
# bash rand2.sh

# random generator method2
verbose=0

function  xor()
{
      local res=(`echo "$1" | sed "s/../0x& /g"`)
      shift 1
      while [[ "$1" ]]; do
            local one=(`echo "$1" | sed "s/../0x& /g"`)
            local count1=${#res[@]}
            if [ $count1 -lt ${#one[@]} ]
            then
                  count1=${#one[@]}
            fi
            for (( i = 0; i < $count1; i++ ))
            do
                  res[$i]=$((${one[$i]:-0} ^ ${res[$i]:-0}))
            done
            shift 1
      done
      printf "%02x" "${res[@]}"
} 

[[ $verbose -eq 1 ]] && echo "randomly generate three private keys!"
# sk1="$(openssl rand -hex 50)"
# sk2="$(openssl rand -hex 50)"
# sk3="$(openssl rand -hex 50)"

# printf "user1-sk1: $sk1\n"
# printf "user2-sk2: $sk2\n"
# printf "user3-sk3: $sk3\n\n"

echo "Initialization:"
# the rand seed
msg="$(openssl rand -hex 32)" 
printf "seed: $msg\n\n"

i=1
# number of blocks
while [ $i -le 2000000 ] 
do
	let i++
	# process notification
	if [[ $(($i % 100)) -eq "0" ]]
	then
		printf "\n-----------reaching $i blocks!-----------------\n"
	fi

	if [[ $(($i % 20)) -eq "0" ]]
	then
		echo "refreshing voters every 20 blocks"
		sk1="$(openssl rand -hex 50)"
		sk2="$(openssl rand -hex 50)"
		sk3="$(openssl rand -hex 50)"
		printf "$sk1\n$sk2\n$sk3\n"
	fi

	[[ $verbose -eq 1 ]] && {printf "user1's turn:"}
	pout1="$(./vrf_client -p $sk1 $msg)"
	IFS=';' read -ra data1 <<< "$pout1"
	[[ $verbose -eq 1 ]] && {printf "rand1: ${data1[3]}\n"}

	[[ $verbose -eq 1 ]] && {printf "user2's turn:"}
	pout2="$(./vrf_client -p $sk2 $msg)"
	IFS=';' read -ra data2 <<< "$pout2"
	[[ $verbose -eq 1 ]] && {printf "rand2: ${data2[3]}\n"}

	[[ $verbose -eq 1 ]] && {printf "user3's turn:"}
	pout3="$(./vrf_client -p $sk3 $msg)"
	IFS=';' read -ra data3 <<< "$pout3"
	[[ $verbose -eq 1 ]] && {printf "rand3: ${data3[3]}\n"}

	[[ $verbose -eq 1 ]] && {printf "msg: $msg \n"}
	[[ $verbose -eq 1 ]] && {printf "verifying ${data1[0]} ${data1[1]} ${data1[2]} \n"}
	vout1="$(./vrf_client -v ${data1[0]} ${data1[1]} ${data1[2]})"
	vout2="$(./vrf_client -v ${data2[0]} ${data2[1]} ${data2[2]})"
	vout3="$(./vrf_client -v ${data3[0]} ${data3[1]} ${data3[2]})"
	[[ $verbose -eq 1 ]] && {echo "verfication result: $vout1, $vout2, $vout3"}

	msg="$(xor ${data1[3]} ${data2[3]})" 
	msg="$(xor $msg ${data3[3]})" 

	#use hashed string, u64
	msg="$(echo -n $msg | openssl dgst -sha256)"
	msg="${msg:9:16}"
	[[ $verbose -eq 1 ]] && {printf "rand: $msg\n\n"}

	# print as binary for NIST sp800 test, 16 hex at most, fixed to 64 length
	printf "${msg:0:16}\n"  | perl -ne 'printf "%064b\n", hex($_)' >> sp800test.log
done

cd sts; chmod +x ultRand.sh; ./ultRand.sh
