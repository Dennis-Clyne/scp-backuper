#!/bin/bash

#CONFIG_FILE="${HOME}/scp-backuper/scp_backuper.conf"
#DATE_FILE="${HOME}/.latest_backup_date"
CONFIG_FILE="/etc/scp_backuper/scp_backuper.conf"
DATE_FILE="/etc/scp_backuper/.latest_backup_date"
KNOWN_DIR_FILE="/etc/scp_backuper/known_dir"
USER_NAME=:
IP=:
PORT=:
KEY=:
BACKUP_DIR=: # backup先
BACKUP_TARGET=: # backup元

for line in `cat ${CONFIG_FILE}`; do
        config_file+=($line) 
done

for i in `seq 0 ${#config_file[*]}`; do
        case ${config_file[$i]} in
                "User" ) USER_NAME=${config_file[$i + 1]};;
                "Ip" ) IP=${config_file[$i + 1]};;
                "Port" ) PORT=${config_file[$i + 1]};;
                "Key" ) KEY=${config_file[$i + 1]};;
                "BackupDir" ) BACKUP_DIR=${config_file[$i + 1]};;
                "BackupTarget" ) BACKUP_TARGET=${config_file[$i + 1]};;
        esac
done

#echo "USER_NAME = ${USER_NAME}"
#echo "IP = ${IP}"
#echo "PORT = ${PORT}"
#echo "KEY = ${KEY}"
#echo "BACKUP_DIR = ${BACKUP_DIR}"
#echo "BACKUP_TARGET = ${BACKUP_TARGET}"
#echo "DATE_FILE = ${DATE_FILE}"

##第一引数のディレクトリ内の更新されたファイルやディレクトリをコピーする
explorer () {
        TARGET_FILES="" #更新されてるファイルのパスをスペース区切りで入れる
        fileArray=()
        dirArray=() #既存のディレクトリを入れる配列

        for filePath in ${1}*; do
                if [ -f $filePath ]; then
                        fileArray+=("$filePath")
                fi
        done

        for i in ${fileArray[@]}; do
                if [ $i -nt ${DATE_FILE} ]; then
                        TARGET_FILES="${TARGET_FILES} $i"
                fi
        done

        #echo "TARGET_FILES : ${TARGET_FILES}"

        if [ "$TARGET_FILES" != "" ]; then
                f=`scp -r -i ${KEY} -P ${PORT} ${TARGET_FILES} ${USER_NAME}@${IP}:${BACKUP_DIR}/$2`
                echo $f
        fi

        for i in `ls ${1} -F | grep /`; do
                flag=0 # 既存のディレクトリだったら1になる
                for line in `cat ${KNOWN_DIR_FILE}`; do
                        if [ "$1$i" = $line ]; then
                                flag=1
                                dirArray+=("$i")
                        fi
                done

                if [ $flag = 0 ]; then
                        f=`scp -r -i ${KEY} -P ${PORT} $1$i ${USER_NAME}@${IP}:${BACKUP_DIR}/$2`
                        echo $f
                        echo "$1$i" >>${KNOWN_DIR_FILE}
                fi
        done

        for i in ${dirArray[@]}; do
                if [ "$1$i" -nt ${DATE_FILE} ]; then
                        explorer "$1$i" "$2$i" "$2"
                fi
        done
}

##known_dirを作るためにディレクトリを集める関数。
##第一引数のディレクトリ内のすべてのディレクトリをfirstDirArrayに入れる。       
firstExplorer() {
        dirArray=()
        for dirPath in ${1}/*; do
                if [ -d $dirPath ]; then
                        firstDirArray+=("$dirPath")
                        dirArray+=("$dirPath")
                fi
        done
        for i in ${dirArray[@]}; do
                firstExplorer $i
        done
}

save_date=`date +%Y/%m/%d`
save_date="${save_date} `date +%H:%M`"

if [ -e $DATE_FILE ]; then
        explorer "${BACKUP_TARGET}/" "./"
        echo $save_date >${DATE_FILE}
else 
        f=`scp -r -i ${KEY} -P ${PORT} ${BACKUP_TARGET}/* ${USER_NAME}@${IP}:${BACKUP_DIR}`
        echo $f

        firstExplorer ${BACKUP_TARGET}
        for i in ${firstDirArray[@]}; do
                echo "${i}/" >>${KNOWN_DIR_FILE}
        done

        echo $save_date >${DATE_FILE}
fi











