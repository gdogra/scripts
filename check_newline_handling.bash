out=`echo -e 'Foo\n\nBar\nBaz\n\n\n\n'`
out=`echo "${out}"|grep -v Bar`

IFS=$'\n'
for entry in $out; do
    echo "---$entry---"
done
