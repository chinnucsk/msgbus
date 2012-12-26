#!/bin/sh
CONVERT_CMD="/opt/openoffice.org3/program/python /opt/DocumentConverter.py"
#CONVERT_CMD="/usr/java/jre1.6.0_18/bin/java -jar /opt/jodconverter/lib/jodconverter-cli-2.2.2.jar -f pdf -p 8100"

while getopts ":d:h:p:a:s:i:o:" opt; do
  case $opt in
	d) dtype=$OPTARG
      ;;
	s) stype=$OPTARG
	;;
	i) input=$OPTARG
	;;
	o) output=$OPTARG
	;;
	h) host=$OPTARG
	;;
	p) port=$OPTARG
	;;
	a) action=$OPTARG
	;;
    	?) echo "
程序控制使用 -h -p -a  -h指定地址  -p指定端口 -a指定指令start或restart

转换使用 -s -d -i -o  -s指定源文件类型  -d指定目标文件类型  -i指定输入文件  -o指定输出文件" ;;
	:)
      echo "Option -$OPTARG requires an argument." >&2
      echo "use ? for help"
	exit 1
      ;;
  esac
done

if [ $host ] && [ $port ] && [ $action ]
then
	if [ $action = "start" ]
	then
		/opt/openoffice.org3/program/soffice -headless -accept="socket,host=$host,port=$port;urp;" -nofirststartwizard -display 0:1 > /dev/null &
		else if [ $action = "restart" ]
		then
			ps aux|grep "/opt/openoffice.org3/program/soffice"|grep -v grep|awk '{print $2}'|xargs kill -9
			sleep 1
			/opt/openoffice.org3/program/soffice -headless -accept="socket,host=$host,port=$port;urp;" -nofirststartwizard -display 0:1 > /dev/null &
		else
			echo "请检查输入的指令"
		fi
	fi
fi

if [ $stype = $dtype ]
        then
                echo "格式相同，无需转换"
                exit 1
                else if [ $stype = "swf" ]
                then
                        echo "已经是SWF格式，无需转换"
                        exit 1
                fi
fi

if [ $dtype = "pdf" ]
then
#/opt/openoffice.org3/program/python /opt/DocumentConverter.py $input $output $stype
$CONVERT_CMD $input $output $stype
fi

if [ $stype = "pdf" ]
then
pdf2swf -p 1-10 $input -o $output -s languagedir=/opt/xpdf -s asprint -T 9 -S
fi

if [ $dtype = "swf" ] && [ $stype != "pdf" ]
then
#/opt/openoffice.org3/program/python /opt/DocumentConverter.py $input /opt/tmp/tmp.pdf $stype  && pdf2swf /opt/tmp/tmp.pdf -o $output -T 9 -f
$CONVERT_CMD $input /opt/tmp/tmp.pdf $stype  && pdf2swf /opt/tmp/tmp.pdf -p 1-10 -o $output -s languagedir=/opt/xpdf -s asprint -T 9 -S
cd /opt/tmp && rm -rf tmp.pdf
fi




#if [ $dtype ] && [ $stype ] && [ $input ] && [ $output ]
#then
#	if [ $stype = $dtype ]
#	then
#		echo "格式相同，无需转换"
#		exit 1
#		else if [ $stype = "swf" ]
#		then
#			echo "已经是SWF格式，无需转换"
#			exit 1
#		fi
#	fi
#	if [ $dtype = "pdf" ]
#	then	
#		/opt/openoffice.org3/program/python /opt/DocumentConverter.py $input $output 
#		else if [ $stype = "pdf" ]
#		then
#			pdf2swf $input -o $output
#			else if [ $dtype = "swf" ] 
#			then
#				/opt/openoffice.org3/program/python /opt/DocumentConverter.py $input /opt/tmp/tmp.pdf
#				pdf2swf /opt/tmp/tmp.pdf -o $output
#				cd /opt/tmp && rm -rf tmp.pdf
#			fi
#		fi
#	fi
#fi
