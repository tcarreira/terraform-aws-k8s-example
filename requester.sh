for i in {0..10000}; do
	[ $(( i%100 )) == 0 ]  && echo $i  
	( curl -sk "https://commentapi.dev/metrics" >/dev/null & )
done

