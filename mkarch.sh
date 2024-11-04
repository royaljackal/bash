#!/bin/bash

while getopts d:n: opts; do
   case ${opts} in
      d) dir_path=${OPTARG} ;;
      n) name=${OPTARG} ;;
   esac
done

if [ -z "$dir_path" ] || [ -z "$name" ]
then
      echo "-d or -n is empty"
      exit 1
fi

dir_path=$(realpath "$dir_path")

cat > "${name}" <<EOF
#!/bin/bash

output_path=.
while getopts o: opts; do
   case \${opts} in
      o) output_path=\${OPTARG} ;;
   esac
done

tar --extract --file ${name}.tar -z -C "\${output_path}"
EOF

declare -a dir_filenames=($(ls "${dir_path}"))

tar --create --file "${name}".tar -z -C "$dir_path" "${dir_filenames[@]}"

chmod +x "${name}"